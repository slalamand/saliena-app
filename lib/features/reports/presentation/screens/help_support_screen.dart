import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/l10n/app_localizations.dart';

/// Help & Support screen with FAQ and contact options.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: SalienaColors.getBackgroundBlue(context),
      appBar: AppBar(
        title: Text(
          'Help & Support',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Section
                _buildSectionHeader(context, l10n.contactUs),
                const SizedBox(height: SalienaSpacing.md),
                _buildContactCard(
                  context,
                  icon: Icons.email_outlined,
                  title: l10n.emailSupport,
                  subtitle: 'support@saliena.lv',
                  onTap: () => _launchEmail('support@saliena.lv'),
                ),
                const SizedBox(height: SalienaSpacing.sm),
                _buildContactCard(
                  context,
                  icon: Icons.phone_outlined,
                  title: l10n.phoneSupport,
                  subtitle: '+371 20 000 000',
                  onTap: () => _launchPhone('+37120000000'),
                ),
                const SizedBox(height: SalienaSpacing.sm),
                _buildContactCard(
                  context,
                  icon: Icons.language_outlined,
                  title: l10n.website,
                  subtitle: 'www.saliena.lv',
                  onTap: () => _launchUrl('https://www.saliena.lv'),
                ),

                const SizedBox(height: SalienaSpacing.xl),

                // FAQ Section
                _buildSectionHeader(context, l10n.frequentlyAskedQuestions),
                const SizedBox(height: SalienaSpacing.md),
                _buildFaqItem(
                  context,
                  question: 'How do I create a report?',
                  answer: 'Tap the + button at the bottom of the screen to create a new report. Fill in the required details, add photos if needed, and submit.',
                ),
                _buildFaqItem(
                  context,
                  question: 'How long does it take to process a report?',
                  answer: 'Most reports are reviewed within 24-48 hours. Complex issues may take longer to resolve.',
                ),
                _buildFaqItem(
                  context,
                  question: 'Can I edit a submitted report?',
                  answer: 'Reports cannot be edited after submission to maintain data integrity. You can add comments to provide additional information.',
                ),
                _buildFaqItem(
                  context,
                  question: 'How do I change my account settings?',
                  answer: 'Go to your Profile tab and tap "Edit Profile" to update your personal information, or "Change Password" to update your password.',
                ),
                _buildFaqItem(
                  context,
                  question: 'What do the report statuses mean?',
                  answer: 'Pending: Report is awaiting review\nIn Progress: Work is being done\nResolved: Issue has been fixed',
                ),

                const SizedBox(height: SalienaSpacing.xl),

                // Support Hours
                Container(
                  decoration: BoxDecoration(
                    color: SalienaColors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(SalienaRadius.lg),
                    border: Border.all(
                      color: SalienaColors.getBorderColor(context),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(SalienaSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: SalienaColors.getIconColor(context),
                          ),
                          const SizedBox(width: SalienaSpacing.sm),
                          Text(
                            l10n.supportHours,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: SalienaColors.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SalienaSpacing.md),
                      Text(
                        'Monday - Friday: 9:00 - 18:00\nSaturday: 10:00 - 14:00\nSunday: Closed',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: SalienaColors.getSecondaryTextColor(context),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: SalienaSpacing.xl),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: SalienaColors.getTextColor(context),
          ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
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
        leading: Container(
          padding: const EdgeInsets.all(SalienaSpacing.sm),
          decoration: BoxDecoration(
            color: SalienaColors.getTertiaryTextColor(context),
            borderRadius: BorderRadius.circular(SalienaRadius.sm),
          ),
          child: Icon(icon, color: SalienaColors.getIconColor(context)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: SalienaColors.getTextColor(context),
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: SalienaColors.getSecondaryTextColor(context),
            fontSize: 14,
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

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: SalienaSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: SalienaColors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(SalienaRadius.lg),
          border: Border.all(
            color: SalienaColors.getBorderColor(context),
            width: 1,
          ),
        ),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: SalienaSpacing.md,
              vertical: SalienaSpacing.xs,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              SalienaSpacing.md,
              0,
              SalienaSpacing.md,
              SalienaSpacing.md,
            ),
            title: Text(
              question,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: SalienaColors.getTextColor(context),
                fontSize: 14,
              ),
            ),
            iconColor: SalienaColors.getIconColor(context),
            collapsedIconColor: SalienaColors.getTertiaryTextColor(context),
            children: [
              Text(
                answer,
                style: TextStyle(
                  color: SalienaColors.getSecondaryTextColor(context),
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
