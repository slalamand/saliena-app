import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/features/auth/domain/entities/user.dart';
import 'package:saliena_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:saliena_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:saliena_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:saliena_app/features/settings/presentation/bloc/settings_state.dart';
import 'package:saliena_app/l10n/app_localizations.dart';
import 'package:saliena_app/routing/routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _initializeControllers(User user) {
    if (_initialized) return;
    _nameController.text = user.fullName;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _addressController.text = user.address ?? '';
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(Routes.login);
        } else if (state is AuthProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profileUpdated),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          _initializeControllers(authState.user);

          return Scaffold(
            backgroundColor: SalienaColors.getBackgroundBlue(context),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    // Constrain to 480 pt on iPad; no effect on phones.
                    child: SalienaAdaptiveContent(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(context, l10n),
                            const SizedBox(height: 32),
                            _buildForm(context, l10n),
                            const SizedBox(height: 32),
                            _buildActionButtons(
                                context, l10n, authState is AuthLoading),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SalienaBottomNav(currentIndex: 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 80,
          child: SalienaLogo(
            withText: false,
            scale: 1.6,
            isDarkBackground:
                Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        Text(
          l10n.profile,
          style: TextStyle(
            color: SalienaColors.getTextColor(context),
            fontSize: 28,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        SalienaTextField(
          controller: _nameController,
          hintText: l10n.nameSurname,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        SalienaTextField(
          controller: _emailController,
          hintText: l10n.email,
          enabled: false,
        ),
        const SizedBox(height: 16),
        SalienaTextField(
          controller: _phoneController,
          hintText: l10n.mobile,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        SalienaTextField(
          controller: _addressController,
          hintText: l10n.residentialAddress,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        _buildLanguageDropdown(context, l10n),
      ],
    );
  }

  Widget _buildLanguageDropdown(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: SalienaColors.getTextFieldBackground(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Locale>(
              value: state.locale,
              icon: Icon(Icons.arrow_drop_down,
                  color: SalienaColors.getIconColor(context)),
              dropdownColor: SalienaColors.getTextFieldBackground(context),
              style: TextStyle(
                color: SalienaColors.getHintColor(context),
                fontSize: 16,
              ),
              items: [
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: const Text('English'),
                ),
                DropdownMenuItem(
                  value: const Locale('lv'),
                  child: const Text('Latviešu'),
                ),
                DropdownMenuItem(
                  value: const Locale('ru'),
                  child: const Text('Русский'),
                ),
              ],
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  context.read<SettingsBloc>().add(ChangeLanguage(newLocale));
                }
              },
              hint: Text(
                l10n.preferredLanguage,
                style:
                    TextStyle(color: SalienaColors.getHintColor(context)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
      BuildContext context, AppLocalizations l10n, bool isLoading) {
    return Column(
      children: [
        SalienaPrimaryButton(
          text: l10n.save,
          isLoading: isLoading,
          onPressed: () {
            context.read<AuthBloc>().add(
                  AuthUpdateProfileRequested(
                    fullName: _nameController.text,
                    phone: _phoneController.text,
                    address: _addressController.text,
                  ),
                );
          },
        ),
        const SizedBox(height: 16),
        SalienaSecondaryButton(
          text: l10n.signOut,
          onPressed: () {
            context.read<AuthBloc>().add(const AuthSignOutRequested());
          },
        ),
        const SizedBox(height: 32),
        Divider(color: Colors.red.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => _confirmDeleteAccount(context, l10n),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This permanently deletes your account and all associated data.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account?\n\n'
          'All your data, reports, and personal information will be removed. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
    }
  }
}
