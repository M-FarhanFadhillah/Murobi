import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/app_widgets.dart';
import 'package:masjid/common/waktu.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/report_store.dart';

// Halaman "Laporkan Permasalahan". Jamaah menulis laporan dan melihat laporan
// miliknya; admin melihat laporan dari semua jamaah (kotak masuk).
class ReportProblemPage extends StatelessWidget {
  const ReportProblemPage({super.key, this.store});

  // Dapat diganti saat pengujian; bawaannya ReportStore.instance.
  final ReportStore? store;

  @override
  Widget build(BuildContext context) {
    return AuthSession.isAdmin
        ? ReportInboxPage(store: store)
        : ReportSendPage(store: store);
  }
}

// Judul halaman dengan tombol kembali (dan tombol muat ulang untuk admin).
class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.title, this.onRefresh});

  final String title;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Kembali',
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppPalette.primaryDark,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppPalette.primaryDark,
              ),
            ),
          ),
          // Penyeimbang lebar tombol kembali agar judul tepat di tengah.
          if (onRefresh == null)
            const SizedBox(width: 48)
          else
            IconButton(
              onPressed: onRefresh,
              tooltip: 'Muat ulang',
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppPalette.primaryDark,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Jamaah: menulis laporan
// ---------------------------------------------------------------------------

class ReportSendPage extends StatefulWidget {
  const ReportSendPage({super.key, ReportStore? store}) : _store = store;

  final ReportStore? _store;

  @override
  State<ReportSendPage> createState() => _ReportSendPageState();
}

class _ReportSendPageState extends State<ReportSendPage> {
  late final ReportStore _store = widget._store ?? ReportStore.instance;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (_sending) return;
    if (text.length < 5) {
      _snack('Isi laporan minimal 5 karakter.');
      return;
    }

    setState(() => _sending = true);
    final ok = await _store.send(text);
    if (!mounted) return;
    setState(() => _sending = false);

    if (!ok) {
      _snack(_store.writeError ?? 'Laporan gagal dikirim.');
      return;
    }
    _textController.clear();
    // Gulir ke laporan terbaru setelah daftar diperbarui.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const _ReportHeader(title: 'Laporkan Permasalahan'),
              Expanded(
                child: ListenableBuilder(
                  listenable: _store,
                  builder: (context, _) => _buildMessages(),
                ),
              ),
              _buildInputField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessages() {
    // Terlama di atas seperti percakapan (daftar toko: terbaru di atas).
    final reports = _store.items.reversed.toList();

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const _Bubble(
          text: "Assalamu'alaikum. Ceritakan kendala yang Anda alami saat "
              'memakai aplikasi MUROBI. Laporan Anda akan dibaca oleh admin masjid.',
          mine: false,
        ),
        if (_store.loading && reports.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_store.error != null && reports.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                Text(
                  _store.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppPalette.textMuted),
                ),
                TextButton(
                  onPressed: _store.load,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        for (final report in reports)
          _Bubble(
            key: ValueKey('laporan-${report.id}'),
            text: report.pesan,
            mine: true,
            caption: report.selesai
                ? 'Sudah ditangani admin'
                : 'Terkirim · ${waktuRelatif(report.waktu)}',
            captionColor: report.selesai ? AppPalette.primary : null,
          ),
      ],
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppPalette.softShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                maxLength: 1000,
                maxLines: null,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Tulis laporan...',
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
            Material(
              color: AppPalette.primary,
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: _sending ? null : _send,
                tooltip: 'Kirim',
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.text,
    required this.mine,
    this.caption,
    this.captionColor,
  });

  final String text;
  final bool mine;
  final String? caption;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(18);
    const tail = Radius.circular(4);

    return Container(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: mine ? AppPalette.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: radius,
                  topRight: radius,
                  bottomLeft: mine ? radius : tail,
                  bottomRight: mine ? tail : radius,
                ),
                boxShadow: AppPalette.softShadow,
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: mine ? Colors.white : AppPalette.textDark,
                  height: 1.4,
                ),
              ),
            ),
            if (caption != null)
              Padding(
                padding: const EdgeInsets.only(top: 3, right: 4),
                child: Text(
                  caption!,
                  style: TextStyle(
                    fontSize: 11,
                    color: captionColor ?? AppPalette.textMuted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Admin: kotak masuk laporan jamaah
// ---------------------------------------------------------------------------

class ReportInboxPage extends StatefulWidget {
  const ReportInboxPage({super.key, ReportStore? store}) : _store = store;

  final ReportStore? _store;

  @override
  State<ReportInboxPage> createState() => _ReportInboxPageState();
}

class _ReportInboxPageState extends State<ReportInboxPage> {
  late final ReportStore _store = widget._store ?? ReportStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleDone(Laporan report) async {
    final ok = await _store.setSelesai(report.id, !report.selesai);
    if (!mounted || ok) return;
    _snack(_store.writeError ?? 'Perubahan gagal disimpan.');
  }

  Future<void> _confirmDelete(Laporan report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus laporan?'),
        content: Text('Laporan dari ${report.nama} akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppPalette.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final ok = await _store.remove(report.id);
    if (!mounted) return;
    _snack(ok ? 'Laporan dihapus.' : _store.writeError ?? 'Laporan gagal dihapus.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _ReportHeader(title: 'Laporan Masalah', onRefresh: _store.load),
              Expanded(
                child: ListenableBuilder(
                  listenable: _store,
                  builder: (context, _) => _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final reports = _store.items;

    if (_store.loading && reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_store.error != null && reports.isEmpty) {
      return _Message(
        icon: Icons.cloud_off_rounded,
        text: _store.error!,
        action: TextButton(onPressed: _store.load, child: const Text('Coba lagi')),
      );
    }

    return RefreshIndicator(
      onRefresh: _store.load,
      child: reports.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                _Message(
                  icon: Icons.inbox_outlined,
                  text: 'Belum ada laporan dari jamaah.',
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: reports.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildSummary();
                final report = reports[index - 1];
                return _ReportCard(
                  key: ValueKey('laporan-${report.id}'),
                  report: report,
                  onToggleDone: () => _toggleDone(report),
                  onDelete: () => _confirmDelete(report),
                );
              },
            ),
    );
  }

  Widget _buildSummary() {
    final total = _store.items.length;
    final baru = _store.belumSelesai;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        baru == 0
            ? '$total laporan, semuanya sudah ditangani'
            : '$baru laporan baru dari $total laporan',
        style: const TextStyle(color: AppPalette.textMuted, fontSize: 13),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppPalette.textMuted),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppPalette.textMuted),
            ),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    super.key,
    required this.report,
    required this.onToggleDone,
    required this.onDelete,
  });

  final Laporan report;
  final VoidCallback onToggleDone;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final done = report.selesai;
    final initial =
        report.nama.trim().isEmpty ? '?' : report.nama.trim()[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppPalette.primary.withOpacity(0.14),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppPalette.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppPalette.textDark,
                        ),
                      ),
                      Text(
                        report.email.isEmpty
                            ? waktuRelatif(report.waktu)
                            : '${report.email} · ${waktuRelatif(report.waktu)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppPalette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: (done ? AppPalette.primary : AppPalette.gold)
                        .withOpacity(0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    done ? 'Selesai' : 'Baru',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: done
                          ? AppPalette.primary
                          : const Color(0xFF8A5A00),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.pesan,
              style: const TextStyle(color: AppPalette.textDark, height: 1.4),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onToggleDone,
                  icon: Icon(
                    done ? Icons.undo_rounded : Icons.check_circle_outline,
                    size: 18,
                  ),
                  label: Text(done ? 'Buka lagi' : 'Tandai selesai'),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Hapus laporan',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppPalette.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
