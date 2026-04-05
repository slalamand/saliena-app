import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saliena_app/design_system/theme/colors.dart';
import 'package:saliena_app/routing/routes.dart';
import 'package:saliena_app/l10n/app_localizations.dart';

class SalienaBottomNav extends StatelessWidget {
  final int currentIndex;

  const SalienaBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: SalienaColors.getBackgroundBlue(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            index: 0,
            icon: Icons.photo_camera_outlined,
            label: l10n.report,
            route: Routes.createReport,
          ),
          _buildNavItem(
            context,
            index: 1,
            icon: Icons.list_alt_outlined,
            label: l10n.issues,
            route: Routes.myReports,
          ),
          _buildNavItem(
            context,
            index: 2,
            icon: Icons.person_outline,
            label: l10n.profile,
            route: Routes.profile,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isSelected = currentIndex == index;
    final color = SalienaColors.getTextColor(context);
    
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          // Use pushReplacement for seamless navigation between bottom nav screens
          context.pushReplacement(route);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected 
                  ? Border.all(color: color, width: 2) 
                  : null,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
