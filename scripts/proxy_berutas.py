"""Proxy bertitik-banyak (threaded) di depan `php -S` yang hanya melayani satu
permintaan sekali waktu. Hanya untuk pengujian/demo lokal (pakai Apache XAMPP untuk yang sungguhan).
Dipakai oleh scripts/server-laravel.bat: proxy di port 8000, php -S di port 8001.

Pemakaian: python proxy_berutas.py LISTEN_PORT BACKEND_PORT
Header Host asli diteruskan agar url() Laravel menghasilkan alamat yang benar.
Setiap permintaan dikirim ke PHP dalam SATU paket lewat socket mentah, karena
server bawaan PHP di Windows kadang mereset koneksi bila body datang terpisah.
Mencatat waktu tiap permintaan ke %TEMP%\murobi-proxy.log.
"""
import os
import socket
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

LISTEN_PORT = int(sys.argv[1])
BACKEND_PORT = int(sys.argv[2])
CRLF = chr(13) + chr(10)
HOP_BY_HOP = {'connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization',
              'te', 'trailers', 'transfer-encoding', 'upgrade'}
backend_lock = threading.Lock()  # PHP melayani satu permintaan sekali waktu.
LOG = os.path.join(os.environ.get('TEMP', '.'), 'murobi-proxy.log')
log_lock = threading.Lock()


def log(message):
    with log_lock, open(LOG, 'a', encoding='utf-8') as f:
        f.write('%.3f %s\n' % (time.time() % 1000, message))


def forward(method, path, headers, body):
    lines = ['%s %s HTTP/1.1' % (method, path)]
    for key, value in headers.items():
        if key.lower() != 'content-length':
            lines.append('%s: %s' % (key, value))
    if body is not None:
        lines.append('Content-Length: %d' % len(body))
    raw = (CRLF.join(lines) + CRLF + CRLF).encode('latin-1') + (body or b'')
    last_error = None
    # Hanya permintaan aman yang boleh diulang; mengulang POST menggandakan data.
    attempts = 3 if method in ('GET', 'HEAD', 'OPTIONS') else 1
    for _ in range(attempts):
        sock = socket.create_connection(('127.0.0.1', BACKEND_PORT), timeout=60)
        try:
            sock.sendall(raw)
            chunks = []
            while True:
                part = sock.recv(65536)
                if not part:
                    break
                chunks.append(part)
            blob = b''.join(chunks)
            head, _, payload = blob.partition((CRLF + CRLF).encode())
            head_lines = head.decode('latin-1').split(CRLF)
            parts = head_lines[0].split(' ', 2)
            status = int(parts[1])
            reason = parts[2] if len(parts) > 2 else ''
            resp_headers = [tuple(h.split(': ', 1)) for h in head_lines[1:] if ': ' in h]
            return status, reason, resp_headers, payload
        except (ConnectionResetError, ValueError, IndexError) as error:
            last_error = error
            time.sleep(0.2)
        finally:
            sock.close()
    raise last_error


class Proxy(BaseHTTPRequestHandler):
    protocol_version = 'HTTP/1.0'  # tutup koneksi setiap respons
    timeout = 120  # koneksi menganggur dari browser tidak menahan thread selamanya

    def do_any(self):
        started = time.time()
        label = '%s %s' % (self.command, self.path)
        length = int(self.headers.get('Content-Length') or 0)
        body = self.rfile.read(length) if length else None
        headers = {k: v for k, v in self.headers.items() if k.lower() not in HOP_BY_HOP}
        headers['Connection'] = 'close'
        waited = 0.0
        try:
            t0 = time.time()
            with backend_lock:
                waited = time.time() - t0
                status, reason, resp_headers, data = forward(self.command, self.path, headers, body)
        except Exception as error:  # noqa: BLE001
            log('ERR  %s -> %r' % (label, error))
            self.send_error(502, 'Backend error: %s' % error)
            return
        self.send_response(status, reason)
        for key, value in resp_headers:
            if key.lower() not in HOP_BY_HOP and key.lower() != 'content-length':
                self.send_header(key, value)
        self.send_header('Content-Length', str(len(data)))
        self.send_header('Connection', 'close')
        self.end_headers()
        if self.command != 'HEAD':
            try:
                self.wfile.write(data)
            except (BrokenPipeError, ConnectionResetError, socket.timeout) as error:
                log('WRITE-FAIL %s -> %r' % (label, error))
                return
        log('%d %s waited=%.2fs total=%.2fs bytes=%d' % (status, label, waited, time.time() - started, len(data)))

    do_GET = do_POST = do_PATCH = do_PUT = do_DELETE = do_OPTIONS = do_HEAD = do_any

    def log_message(self, fmt, *args):
        pass


class Server(ThreadingHTTPServer):
    request_queue_size = 256  # bawaan 5: koneksi paralel browser banyak yang gagal
    daemon_threads = True

    def handle_error(self, request, client_address):
        import traceback
        log('HANDLER-ERROR from %s: %s' % (client_address, traceback.format_exc().strip().splitlines()[-1]))


if __name__ == '__main__':
    Server(('127.0.0.1', LISTEN_PORT), Proxy).serve_forever()
