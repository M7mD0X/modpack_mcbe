import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  bool _canResend = false;
  int _resendCooldown = 60;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendCooldown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
        _startResendCooldown();
      } else if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    // Auto-submit when all filled
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length == 6) {
      _verify(code);
    }
  }

  void _onBackspace(int index) {
    if (index > 0) {
      _otpControllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify(String code) async {
    if (_isVerifying) return;

    setState(() => _isVerifying = true);

    final auth = context.read<AuthService>();
    final success = await auth.verifyEmail(widget.email, code);

    if (mounted) {
      if (success) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email verified successfully!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() => _isVerifying = false);
        // Clear all fields
        for (final c in _otpControllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Verification failed'),
            backgroundColor: AppTheme.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;

    final auth = context.read<AuthService>();
    final success = await auth.resendVerification(widget.email);

    if (mounted) {
      if (success) {
        setState(() {
          _canResend = false;
          _resendCooldown = 60;
        });
        _startResendCooldown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification code sent!'),
            backgroundColor: AppTheme.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Failed to resend'),
            backgroundColor: AppTheme.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _skip() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
        ),
        title: const Text('Verify Email'),
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text(
              'Skip',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppTheme.spacingMd),

            // Header
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.mark_email_unread_rounded,
                size: 36,
                color: AppTheme.info.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Check your email',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'We sent a verification code to\n${widget.email}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXxl),

            // OTP Input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  width: 48,
                  height: 56,
                  margin: EdgeInsets.symmetric(
                    horizontal: index == 0 ||
                            index == 5
                        ? 0
                        : 4,
                  ),
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    cursorColor: AppTheme.primary,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.card,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        borderSide:
                            BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                    ),
                    onChanged: (value) => _onOtpChanged(index, value),
                    onSubmitted: (_) {
                      if (index == 5) {
                        final code =
                            _otpControllers.map((c) => c.text).join();
                        if (code.length == 6) _verify(code);
                      }
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: AppTheme.spacingXxl),

            // Verify button
            FilledButton(
              onPressed: _isVerifying
                  ? null
                  : () {
                      final code =
                          _otpControllers.map((c) => c.text).join();
                      if (code.length == 6) _verify(code);
                    },
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
              ),
              child: _isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.textOnPrimary,
                      ),
                    )
                  : const Text(
                      'Verify',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Resend
            Center(
              child: _canResend
                  ? TextButton(
                      onPressed: _resend,
                      child: const Text('Resend Code'),
                    )
                  : Text(
                      'Resend in ${_resendCooldown}s',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
