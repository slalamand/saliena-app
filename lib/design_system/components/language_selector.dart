import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saliena_app/design_system/theme/colors.dart';
import 'package:saliena_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:saliena_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:saliena_app/features/settings/presentation/bloc/settings_state.dart';

class LanguageSelector extends StatelessWidget {
  final bool compact;

  const LanguageSelector({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: SalienaColors.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: SalienaColors.getBorderColor(context),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageButton(
                code: 'en',
                label: 'ENG',
                isSelected: state.locale.languageCode == 'en',
                onTap: () => context.read<SettingsBloc>().add(const ChangeLanguage(Locale('en'))),
              ),
              _LanguageButton(
                code: 'ru',
                label: 'RUS',
                isSelected: state.locale.languageCode == 'ru',
                onTap: () => context.read<SettingsBloc>().add(const ChangeLanguage(Locale('ru'))),
              ),
              _LanguageButton(
                code: 'lv',
                label: 'LV',
                isSelected: state.locale.languageCode == 'lv',
                onTap: () => context.read<SettingsBloc>().add(const ChangeLanguage(Locale('lv'))),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String code;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? SalienaColors.getNavy(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : SalienaColors.getSecondaryTextColor(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
