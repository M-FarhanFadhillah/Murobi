import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/app_widgets.dart';

// Halaman "Laporkan Permasalahan". Saat ini masih simulasi di perangkat:
// pesan belum dikirim ke server dan balasan admin dibuat otomatis.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [
    const ChatMessage(
      text: "Assalamu'alaikum. Ceritakan kendala yang Anda alami saat memakai "
          'aplikasi MUROBI, kami siap membantu.',
      isCustomer: false,
    ),
  ];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isCustomer: true));
      // Simulasi balasan admin.
      _messages.add(const ChatMessage(
        text: 'Terima kasih atas laporan Anda.',
        isCustomer: false,
      ));
      _textController.clear();
    });

    // Gulir ke pesan terbaru setelah daftar diperbarui.
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
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => _messages[index],
                ),
              ),
              _buildInputField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          const Expanded(
            child: Text(
              'Laporkan Permasalahan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppPalette.primaryDark,
              ),
            ),
          ),
          // Penyeimbang lebar tombol kembali agar judul tepat di tengah.
          const SizedBox(width: 48),
        ],
      ),
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
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan...',
                  border: InputBorder.none,
                ),
              ),
            ),
            Material(
              color: AppPalette.primary,
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: _sendMessage,
                tooltip: 'Kirim',
                icon: const Icon(
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

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isCustomer;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isCustomer,
  });

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(18);
    const tail = Radius.circular(4);

    return Container(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isCustomer ? AppPalette.primary : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: radius,
              topRight: radius,
              bottomLeft: isCustomer ? radius : tail,
              bottomRight: isCustomer ? tail : radius,
            ),
            boxShadow: AppPalette.softShadow,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isCustomer ? Colors.white : AppPalette.textDark,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
