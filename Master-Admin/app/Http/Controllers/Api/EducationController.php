<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\education;
use App\Support\FileUrl;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

/**
 * Materi edukasi. jenis_education_id: 1 = Buku (artikel; berkas gambar atau PDF),
 * 2 = Video (berkas video, atau tautan video seperti YouTube yang disimpan
 * apa adanya di kolom `content`).
 */
class EducationController extends Controller
{
    private const BOOK = 1;
    private const VIDEO = 2;

    public function book()
    {
        return response()->json($this->withUrls(education::where('jenis_education_id', self::BOOK)->get()));
    }

    public function video()
    {
        return response()->json($this->withUrls(education::where('jenis_education_id', self::VIDEO)->get()));
    }

    /**
     * Menambah materi (admin). multipart/form-data.
     * jenis = book | video. Buku: `content` (gambar/PDF) opsional.
     * Video: `content` (berkas video) ATAU `video_url`.
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'jenis' => ['required', 'in:book,video'],
            'judul' => ['required', 'string', 'max:255'],
            'kategori' => ['required', 'integer', 'between:0,2'],
            'deskripsi' => ['required', 'string', 'max:20000'],
            'content' => ['nullable', 'file', 'max:' . self::maxKb()],
            'video_url' => ['nullable', 'url', 'max:255'],
        ], self::messages());

        $isVideo = $data['jenis'] === 'video';
        $this->validateContent($request, $isVideo);

        $content = '';
        if ($request->hasFile('content')) {
            $content = $request->file('content')->store('konten-edukasi');
        } elseif ($isVideo) {
            $content = $data['video_url'];
        }

        $item = education::create([
            'jenis_education_id' => $isVideo ? self::VIDEO : self::BOOK,
            'judul' => trim($data['judul']),
            'kategori' => $data['kategori'],
            'content' => $content,
            'deskripsi' => trim($data['deskripsi']),
        ]);

        return response()->json($this->present($item), 201);
    }

    /**
     * Mengubah materi (admin), lewat POST multipart. Jenis tidak dapat diubah.
     * `content` baru atau `video_url` baru mengganti isi lama.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $item = education::findOrFail($id);
        $isVideo = (int) $item->jenis_education_id === self::VIDEO;

        $data = $request->validate([
            'judul' => ['sometimes', 'string', 'max:255'],
            'kategori' => ['sometimes', 'integer', 'between:0,2'],
            'deskripsi' => ['sometimes', 'string', 'max:20000'],
            'content' => ['sometimes', 'file', 'max:' . self::maxKb()],
            'video_url' => ['sometimes', 'nullable', 'url', 'max:255'],
        ], self::messages());
        $this->validateContent($request, $isVideo, true);

        $old = null;
        if ($request->hasFile('content')) {
            $old = $item->content;
            $item->content = $request->file('content')->store('konten-edukasi');
        } elseif ($isVideo && !empty($data['video_url'])) {
            $old = $item->content;
            $item->content = $data['video_url'];
        }
        foreach (['judul', 'kategori', 'deskripsi'] as $field) {
            if (array_key_exists($field, $data)) {
                $item->{$field} = is_string($data[$field]) ? trim($data[$field]) : $data[$field];
            }
        }
        $item->save();

        $this->deleteStored($old);

        return response()->json($this->present($item));
    }

    public function destroy(int $id): JsonResponse
    {
        $item = education::findOrFail($id);
        $content = $item->content;
        $item->delete();
        $this->deleteStored($content);

        return response()->json(['message' => 'Materi dihapus.']);
    }

    /**
     * Aturan jenis berkas: buku = gambar atau PDF; video = mp4/webm/mov.
     * Video baru wajib punya berkas atau tautan.
     */
    private function validateContent(Request $request, bool $isVideo, bool $update = false): void
    {
        $rules = [];
        if ($request->hasFile('content')) {
            $rules['content'] = $isVideo
                ? ['mimes:mp4,webm,mov,m4v']
                : ['mimes:jpg,jpeg,png,webp,pdf'];
        } elseif ($isVideo && !$update && !$request->filled('video_url')) {
            $rules['content'] = ['required'];
        }
        if (!$isVideo && $request->filled('video_url')) {
            $rules['video_url'] = ['prohibited'];
        }

        if ($rules) {
            $request->validate($rules, self::messages());
        }
    }

    private function deleteStored(?string $path): void
    {
        // Tautan (http...) bukan berkas di disk, dan jalur yang tidak ada diabaikan.
        if ($path && !preg_match('#^https?://#i', $path)) {
            Storage::disk(config('filesystems.default'))->delete($path);
        }
    }

    // Menambahkan content_url (alamat berkas, atau tautan video) tanpa mengubah field lama.
    private function withUrls($items)
    {
        return $items->map(fn ($item) => $this->present($item));
    }

    private function present(education $item): array
    {
        return array_merge($item->toArray(), [
            // Setelah tambah/ubah, atribut masih berupa string dari form; samakan
            // dengan daftar (angka) agar klien tidak perlu menebak tipe.
            'jenis_education_id' => (int) $item->jenis_education_id,
            'kategori' => (int) $item->kategori,
            'content_url' => preg_match('#^https?://#i', (string) $item->content)
                ? $item->content
                : FileUrl::for($item->content),
        ]);
    }

    private static function maxKb(): int
    {
        return 30 * 1024;
    }

    private static function messages(): array
    {
        return [
            'jenis.required' => 'Jenis materi wajib dipilih.',
            'jenis.in' => 'Jenis materi harus book atau video.',
            'judul.required' => 'Judul wajib diisi.',
            'kategori.required' => 'Kategori wajib dipilih.',
            'kategori.between' => 'Kategori tidak dikenal.',
            'deskripsi.required' => 'Isi atau deskripsi wajib diisi.',
            'content.required' => 'Video wajib berisi berkas atau tautan.',
            'content.max' => 'Ukuran berkas maksimal 30 MB.',
            'content.mimes' => 'Jenis berkas tidak didukung.',
            'content.uploaded' => 'Berkas gagal diunggah. Ukuran maksimal 30 MB.',
            'video_url.url' => 'Tautan video tidak valid.',
            'video_url.prohibited' => 'Tautan video hanya untuk materi video.',
        ];
    }
}
