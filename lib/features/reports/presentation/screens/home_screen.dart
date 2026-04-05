import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/l10n/app_localizations.dart';
import 'package:saliena_app/routing/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: SalienaColors.getBackgroundBlue(context),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuButton(
                context,
                icon: Icons.photo_camera_outlined,
                label: l10n.report,
                backgroundColor: SalienaColors.iconYellow,
                iconColor: Colors.white,
                onTap: () => context.push(Routes.createReport),
              ),
              const SizedBox(height: 80),
              _buildMenuButton(
                context,
                icon: Icons.list_alt,
                label: l10n.issues,
                backgroundColor: SalienaColors.iconGreen,
                iconColor: Colors.white,
                onTap: () => context.push(Routes.myReports),
              ),
              const SizedBox(height: 80),
              _buildMenuButton(
                context,
                icon: Icons.person,
                label: l10n.profile,
                backgroundColor: Colors.transparent,
                iconColor: SalienaColors.iconBlue,
                isOutlined: true,
                onTap: () => context.push(Routes.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          if (isOutlined)
            Icon(
              icon,
              color: iconColor,
              size: 56,
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: SalienaColors.getTextColor(context),
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
