import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  int _step = 1; // 1: email, 2: code, 3: new password

  static const String baseUrl = 'http://10.0.2.2:8080';

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (var c in _codeControllers) c.dispose();
    for (var f in _codeFocusNodes) f.dispose();
    super.dispose();
  }

  String get _code => _codeControllers.map((c) => c.text).join();

  Future<void> _sendCode() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'E-posta adresinizi girin');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );

      if (response.statusCode == 200) {
        setState(() => _step = 2);
      } else {
        final data = jsonDecode(response.body);
        setState(() => _errorMessage = data['error'] ?? 'Bir hata oluştu');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Bağlantı hatası');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_code.length < 6) {
      setState(() => _errorMessage = '6 haneli kodu girin');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'code': _code,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _step = 3);
      } else {
        final data = jsonDecode(response.body);
        setState(() => _errorMessage = data['error'] ?? 'Geçersiz kod');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Bağlantı hatası');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.length < 6) {
      setState(() => _errorMessage = 'Şifre en az 6 karakter olmalı');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Şifreler eşleşmiyor');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'code': _code,
          'newPassword': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Şifreniz başarıyla güncellendi!')),
          );
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() => _errorMessage = data['error'] ?? 'Bir hata oluştu');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Bağlantı hatası');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
          onPressed: () {
            if (_step > 1) {
              setState(() {
                _step--;
                _errorMessage = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildStepIndicator(),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _step == 1
                    ? _buildEmailStep()
                    : _step == 2
                    ? _buildCodeStep()
                    : _buildPasswordStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (index) => Expanded(
        child: Container(
          height: 4,
          margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
          decoration: BoxDecoration(
            color: index < _step ? AppTheme.terracotta : AppTheme.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      )),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: AppTheme.terracottaLight, borderRadius: BorderRadius.circular(32)),
          child: const Icon(Icons.lock_reset_outlined, color: AppTheme.terracotta, size: 32),
        ),
        const SizedBox(height: 24),
        const Text('Şifreni Sıfırla', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text('E-posta adresini gir, sıfırlama kodu gönderelim.', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
        const SizedBox(height: 32),
        Text('E-POSTA', style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'E-posta adresiniz',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.terracottaLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.terracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Kod Gönder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      key: const ValueKey('code'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: AppTheme.terracottaLight, borderRadius: BorderRadius.circular(32)),
          child: const Icon(Icons.mark_email_unread_outlined, color: AppTheme.terracotta, size: 32),
        ),
        const SizedBox(height: 24),
        const Text('Kodu Gir', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text('${_emailController.text} adresine gönderilen 6 haneli kodu gir.', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => SizedBox(
            width: 48, height: 56,
            child: TextField(
              controller: _codeControllers[index],
              focusNode: _codeFocusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.terracotta, width: 2)),
              ),
              onChanged: (value) {
                if (value.isNotEmpty && index < 5) {
                  _codeFocusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  _codeFocusNodes[index - 1].requestFocus();
                }
                if (_code.length == 6) _verifyCode();
              },
            ),
          )),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.terracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Doğrula', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _sendCode,
            child: Text('Kodu tekrar gönder', style: TextStyle(color: AppTheme.terracotta)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      key: const ValueKey('password'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: AppTheme.terracottaLight, borderRadius: BorderRadius.circular(32)),
          child: const Icon(Icons.lock_outlined, color: AppTheme.terracotta, size: 32),
        ),
        const SizedBox(height: 24),
        const Text('Yeni Şifre', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text('Yeni şifreni belirle.', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        const SizedBox(height: 32),
        Text('YENİ ŞİFRE', style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'En az 6 karakter',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.terracottaLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppTheme.textSecondary),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('ŞİFRE TEKRAR', style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            hintText: 'Şifreni tekrar gir',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.terracottaLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppTheme.textSecondary),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.terracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Şifremi Güncelle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}