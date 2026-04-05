import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:saliena_app/features/auth/presentation/widgets/country_selector.dart';
import 'package:saliena_app/routing/routes.dart';
import 'package:saliena_app/l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  Country _selectedCountry = const Country(
    name: 'Latvia',
    code: 'LV',
    dialCode: '+371',
    flag: '🇱🇻',
  );

  @override
  void initState() {
    super.initState();
    _updatePhonePrefix();
  }

  void _updatePhonePrefix() {
    // Clear the text field when country changes - don't prepend dial code
    // The dial code is already shown in the prefix icon
    final currentText = _phoneController.text;
    // Remove any existing dial code prefix from the text
    final numberPart = currentText.replaceAll(RegExp(r'^\+\d+\s*'), '');
    _phoneController.text = numberPart;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = null;
      });
      // Combine dial code with the entered phone number
      final phoneNumber = '${_selectedCountry.dialCode}${_phoneController.text.trim()}';
      context.read<AuthBloc>().add(
            AuthSignUpRequested(
              email: _emailController.text.trim(),
              phone: phoneNumber,
              fullName: _fullNameController.text.trim(),
              address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
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
        backgroundColor: SalienaColors.backgroundLightBlue,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildSignupForm(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SalienaLogo(
          withText: true,
          scale: 1.0,
        ),
        const SizedBox(height: 40),
        Text(
          AppLocalizations.of(context)!.createAccount,
          style: const TextStyle(
            color: SalienaColors.navy,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.joinCommunity,
          style: TextStyle(
            color: SalienaColors.navy.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error message
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

            // Full Name
            SalienaTextField(
              controller: _fullNameController,
              labelText: AppLocalizations.of(context)!.fullName,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.nameRequired;
                }
                if (value.length < 2) {
                  return AppLocalizations.of(context)!.nameMinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            SalienaTextField(
              controller: _emailController,
              labelText: AppLocalizations.of(context)!.emailAddress,
              hintText: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.emailRequired;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return AppLocalizations.of(context)!.emailInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone with country selector
            Container(
              decoration: BoxDecoration(
                color: SalienaColors.getTextFieldBackground(context),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: SalienaColors.getTextColor(context), fontSize: 16),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumber,
                  labelStyle: TextStyle(color: SalienaColors.getHintColor(context)),
                  hintStyle: TextStyle(color: SalienaColors.getTertiaryTextColor(context)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CountrySelector(
                          selectedCountry: _selectedCountry,
                          onCountrySelected: (country) {
                            setState(() {
                              _selectedCountry = country;
                              _updatePhonePrefix();
                            });
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.only(left: 12, right: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCountry.flag,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedCountry.dialCode,
                            style: TextStyle(
                              fontSize: 14,
                              color: SalienaColors.navy.withValues(alpha: 0.8),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: SalienaColors.navy.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.phoneRequired;
                  }
                  final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digitsOnly.length < 7) {
                    return AppLocalizations.of(context)!.phoneInvalid;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Residential Address
            SalienaTextField(
              controller: _addressController,
              labelText: 'Residential Address',
              hintText: 'Street, City, Postal Code',
              keyboardType: TextInputType.streetAddress,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Terms text
            Text(
              AppLocalizations.of(context)!.termsAgreement,
              style: TextStyle(
                color: SalienaColors.navy.withValues(alpha: 0.6),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Sign Up button
            SalienaPrimaryButton(
              text: AppLocalizations.of(context)!.createAccount,
              onPressed: _handleSignup,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.hasAccount,
          style: TextStyle(
            color: SalienaColors.navy.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => context.go(Routes.login),
          child: Text(
            AppLocalizations.of(context)!.signIn,
            style: const TextStyle(
              color: SalienaColors.navy,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
