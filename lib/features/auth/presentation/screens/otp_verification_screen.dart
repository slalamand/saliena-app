import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:saliena_app/l10n/app_localizations.dart';
import 'package:saliena_app/routing/routes.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60;
    });
    _countDown();
  }

  void _countDown() {
    if (_resendCountdown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _resendCountdown--;
          });
          _countDown();
        }
      });
    }
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _handleVerify() {
    final otp = _otp;
    
    if (otp.length == 6) {
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });
      FocusScope.of(context).unfocus();
      
      context.read<AuthBloc>().add(AuthVerifyOtpRequested(otp: otp));
    }
  }

  void _handleResend() {
    if (_resendCountdown == 0) {
      context.read<AuthBloc>().add(const AuthResendOtpRequested());
      _startResendCountdown();
    }
  }

  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }
    
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_otp.length == 6) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _otp.length == 6) {
          _handleVerify();
        }
      });
    }
  }

  void _handlePaste(String pastedText) {
    final digits = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digits.isEmpty) return;
    
    for (int i = 0; i < 6 && i < digits.length; i++) {
      _controllers[i].text = digits[i];
    }
    
    final nextEmptyIndex = digits.length < 6 ? digits.length : 5;
    _focusNodes[nextEmptyIndex].requestFocus();
    
    if (digits.length >= 6) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _handleVerify();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        setState(() {
          _isLoading = state is AuthLoading;
        });

        if (state is AuthError) {
          setState(() {
            _errorMessage = state.message;
          });
          for (final controller in _controllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        } else if (state is AuthAwaitingOtpVerification) {
          if (state.errorMessage != null) {
            setState(() {
              _errorMessage = state.errorMessage;
            });
            for (final controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();
          }
        }
      },
      child: Scaffold(
        backgroundColor: SalienaColors.getBackgroundBlue(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: SalienaColors.getTextColor(context)),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthCancelOtpRequested());
              context.go(Routes.login);
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildOtpForm(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        SalienaLogo(withText: false, scale: 0.8, isDarkBackground: isDark),
        const SizedBox(height: 32),
        Text(
          AppLocalizations.of(context)!.verifyPhone,
          style: TextStyle(
            color: SalienaColors.getTextColor(context),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String email = '';
            if (state is AuthAwaitingOtpVerification) {
              email = state.email;
            }
            return Text(
              AppLocalizations.of(context)!.verifyPhoneSubtitle(email),
              style: TextStyle(
                color: SalienaColors.getTextColor(context).withValues(alpha: 0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            );
          },
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) => _buildOtpField(index)),
          ),
          const SizedBox(height: 32),

          SalienaPrimaryButton(
            text: AppLocalizations.of(context)!.verify,
            onPressed: _otp.length != 6 ? null : _handleVerify,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 24),
          
          TextButton(
            onPressed: _resendCountdown == 0 ? _handleResend : null,
            child: Text(
              _resendCountdown > 0
                  ? AppLocalizations.of(context)!.resendCodeIn(_resendCountdown)
                  : AppLocalizations.of(context)!.resendCode,
              style: TextStyle(
                color: _resendCountdown > 0
                    ? SalienaColors.getTextColor(context).withValues(alpha: 0.5)
                    : SalienaColors.getTextColor(context),
                fontWeight: _resendCountdown == 0 ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthCancelOtpRequested());
              context.go(Routes.login);
            },
            child: Text(
              AppLocalizations.of(context)!.backToSignIn,
              style: TextStyle(
                color: SalienaColors.getTextColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: SalienaColors.getTextFieldBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: SalienaColors.getTextColor(context),
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _OtpInputFormatter(index, _handlePaste),
        ],
        onChanged: (value) => _onOtpChanged(index, value),
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _OtpInputFormatter extends TextInputFormatter {
  final int index;
  final void Function(String) onPaste;

  _OtpInputFormatter(this.index, this.onPaste);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    if (newText.length > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onPaste(newText);
      });
      return TextEditingValue(
        text: newText.isNotEmpty ? newText[0] : '',
        selection: const TextSelection.collapsed(offset: 1),
      );
    }
    
    return newValue;
  }
}
