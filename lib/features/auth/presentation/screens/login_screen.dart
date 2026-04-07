import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saliena_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:saliena_app/design_system/design_system.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = null;
      });
      context.read<AuthBloc>().add(
            AuthSignInRequested(
              email: _emailController.text.trim(),
            ),
          );
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
        }
      },
      child: Scaffold(
        backgroundColor: SalienaColors.getBackgroundBlue(context),
        body: SafeArea(
          // SalienaAdaptiveContent centres the entire column at ≤ 480 pt on
          // iPad; on phones (< 480 pt wide) it has no visual effect.
          child: SalienaAdaptiveContent(
            child: Column(
              children: [
                const Spacer(flex: 1),
                // Logo with text
                const SalienaLogo(
                  withText: true,
                  scale: 1.0,
                ),
                const Spacer(flex: 1),

                // Login Form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: _buildLoginForm(context),
                ),

                const Spacer(flex: 2),

                // Footer Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                  child: Text(
                    'Your Saliena Estate account is created for you by the management office',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SalienaColors.getTextColor(context),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],

          // Email field
          SalienaTextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            hintText: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Invalid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Info text about OTP
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: SalienaColors.getPrimaryColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: SalienaColors.getPrimaryColor(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'We\'ll send a verification code to your email',
                    style: TextStyle(
                      color: SalienaColors.getPrimaryColor(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Login button
          SalienaPrimaryButton(
            text: 'Send verification code',
            onPressed: _handleLogin,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
