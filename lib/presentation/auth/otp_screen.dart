import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

import '../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';

/// Phone OTP verification screen.
///
/// [phone] is the E.164-formatted phone number the code was (or will be)
/// sent to, passed via `GoRouterState.extra` when pushing [AppRoutes.otp].
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({required this.phone, super.key});

  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _code = '';

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  void _sendOtp() {
    ref.read(authControllerProvider.notifier).sendPhoneOtp(phone: widget.phone);
  }

  void _verify() {
    if (_code.length != 6) return;
    ref.read(authControllerProvider.notifier).verifyPhoneOtp(
          phone: widget.phone,
          token: _code,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(next.error))),
        );
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.auth_otpTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                '${l10n.auth_otpSubtitle}\n${widget.phone}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              OTPTextField(
                length: 6,
                width: double.infinity,
                fieldWidth: 48,
                style: const TextStyle(fontSize: 18),
                textFieldAlignment: MainAxisAlignment.spaceBetween,
                fieldStyle: FieldStyle.box,
                otpFieldStyle: OtpFieldStyle(
                  enabledBorderColor: Theme.of(context).colorScheme.outline,
                  focusBorderColor: Theme.of(context).colorScheme.primary,
                ),
                onChanged: (value) => _code = value,
                onCompleted: (pin) {
                  _code = pin;
                  _verify();
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : _verify,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.common_confirm),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: isLoading ? null : _sendOtp,
                child: Text(l10n.auth_resendCode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
