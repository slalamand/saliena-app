import 'package:flutter/material.dart';

import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/l10n/app_localizations.dart';

/// About screen with app information.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const appVersion = '1.0.0';
    const buildNumber = '1';

    return Scaffold(
      backgroundColor: SalienaColors.getBackgroundBlue(context),
      appBar: AppBar(
        title: Text(
          l10n.aboutSaliena,
          style: TextStyle(
            color: SalienaColors.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: SalienaColors.getTextColor(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SalienaSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: SalienaSpacing.xl),

              // App Logo
              const SalienaLogo(
                withText: false,
                scale: 1.2,
              ),
              const SizedBox(height: SalienaSpacing.lg),

              // App Name
              Text(
                'Saliena',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: SalienaColors.getTextColor(context),
                ),
              ),
              const SizedBox(height: SalienaSpacing.xs),

              // Version
              Text(
                'Version $appVersion ($buildNumber)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SalienaColors.getTextColor(context).withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: SalienaSpacing.xl),

              // Description
              Container(
                decoration: BoxDecoration(
                  color: SalienaColors.getTextFieldBackground(context),
                  borderRadius: BorderRadius.circular(SalienaRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(SalienaSpacing.lg),
                child: Text(
                  'Saliena is your community reporting app for Saliena municipality. '
                  'Report issues, track progress, and help make our community better.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: SalienaColors.getTextColor(context).withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: SalienaSpacing.lg),

              // Info Cards
              _buildInfoCard(
                context,
                icon: Icons.business,
                title: l10n.developer,
                value: 'Saliena Municipality',
              ),
              const SizedBox(height: SalienaSpacing.sm),
              _buildInfoCard(
                context,
                icon: Icons.email_outlined,
                title: l10n.contact,
                value: 'info@saliena.lv',
              ),
              const SizedBox(height: SalienaSpacing.sm),
              _buildInfoCard(
                context,
                icon: Icons.language,
                title: l10n.website,
                value: 'www.saliena.lv',
              ),

              const SizedBox(height: SalienaSpacing.xl),

              // Legal Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.legal,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: SalienaColors.getTextColor(context),
                  ),
                ),
              ),
              const SizedBox(height: SalienaSpacing.md),

              _buildLegalTile(
                context,
                title: l10n.termsOfService,
                onTap: () => _showLegalDialog(context, l10n.termsOfService),
              ),
              const SizedBox(height: SalienaSpacing.sm),
              _buildLegalTile(
                context,
                title: l10n.privacyPolicy,
                onTap: () => _showLegalDialog(context, l10n.privacyPolicy),
              ),
              const SizedBox(height: SalienaSpacing.sm),
              _buildLegalTile(
                context,
                title: l10n.openSourceLicenses,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Saliena',
                  applicationVersion: appVersion,
                ),
              ),

              const SizedBox(height: SalienaSpacing.xl),

              // Copyright
              Text(
                '© ${DateTime.now().year} Saliena Municipality.\nAll rights reserved.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SalienaColors.getTertiaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: SalienaSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SalienaColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(SalienaRadius.lg),
        border: Border.all(
          color: SalienaColors.getBorderColor(context),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(SalienaSpacing.sm),
          decoration: BoxDecoration(
            color: SalienaColors.getTertiaryTextColor(context),
            borderRadius: BorderRadius.circular(SalienaRadius.sm),
          ),
          child: Icon(icon, color: SalienaColors.getIconColor(context), size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: SalienaColors.getSecondaryTextColor(context),
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: SalienaColors.getTextColor(context),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLegalTile(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SalienaColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(SalienaRadius.lg),
        border: Border.all(
          color: SalienaColors.getBorderColor(context),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: SalienaColors.getTextColor(context),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: SalienaColors.getTertiaryTextColor(context),
        ),
      ),
    );
  }

  void _showLegalDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: SalienaColors.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(SalienaRadius.xl),
          ),
          padding: const EdgeInsets.all(SalienaSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SalienaColors.getTextColor(context),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: SalienaColors.getIconColor(context)),
                  ),
                ],
              ),
              const SizedBox(height: SalienaSpacing.md),
              SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  child: Text(
                    'This is a placeholder for the $title content. '
                    'The actual legal text will be added here.\n\n'
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
                    style: TextStyle(
                      height: 1.6,
                      color: SalienaColors.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
