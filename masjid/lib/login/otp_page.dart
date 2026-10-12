import 'dart:async';

import 'package:flutter/material.dart';
import 'package:masjid/services/api_auth_service.dart';

// Layar kode OTP (sesuai Figma "KODE OTP"). Kode 4 digit, berlaku 60 detik.
class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.phone});

  final String phone;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const int _durationSeconds = 60;
  static const int _digitCount = 4;

  final ApiAuthService _authService = ApiAuthService();
  final List<TextEditingController> _controllers =
      List.generate(_digitCount, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_digitCount, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = _durationSeconds;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _durationSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _resend() async {
    final ok = await _authService.sendOtp(widget.phone);
    if (!mounted) return;
    if (ok) {
      _startTimer();
      setState(() => _errorMessage = null);
    } else {
      setState(() => _errorMessage = 'Gagal mengirim ulang kode OTP.');
    }
  }

  Future<void> _verify() async {
    if (_code.length != _digitCount || _isVerifying) return;
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final ok = await _authService.verifyOtp(widget.phone, _code);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (_) => false);
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Kode OTP salah atau sudah kedaluwarsa.';
      });
    }
  }

  String get _timerText {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildDigitBox(int index) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFF52B69A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < _digitCount - 1) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (_code.length == _digitCount) {
            _verify();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _secondsLeft == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KODE OTP'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFA8FFB0), Color(0xFFA8C8FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _digitCount,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildDigitBox(index),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Masukkan kode OTP',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dikirim ke ${widget.phone}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                if (!isExpired)
                  Text(
                    _timerText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (isExpired) ...[
                  const Text('Kirim ulang kode OTP'),
                  IconButton(
                    onPressed: _resend,
                    icon: const Icon(Icons.refresh, size: 36),
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_isVerifying) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
