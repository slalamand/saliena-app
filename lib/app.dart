import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:saliena_app/core/config/app_config.dart';
import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:saliena_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:saliena_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:saliena_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:saliena_app/features/settings/presentation/bloc/settings_state.dart';
import 'package:saliena_app/injection.dart';
import 'package:saliena_app/routing/app_router.dart';
import 'package:saliena_app/l10n/app_localizations.dart';

/// Root application widget.
/// Sets up theming, localization, and routing.
class SalienaApp extends StatelessWidget {
  const SalienaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested())),
        BlocProvider(create: (_) => getIt<ReportsBloc>()),
        BlocProvider(create: (_) => getIt<SettingsBloc>()..add(LoadSettings())),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          if (settingsState.isLoading) {
            return MaterialApp(
              useInheritedMediaQuery: true,
              locale: DevicePreview.locale(context),
              builder: DevicePreview.appBuilder,
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          return MaterialApp.router(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,

            // Routing
            routerConfig: appRouter,

            // Device Preview
            useInheritedMediaQuery: true,
            locale: DevicePreview.locale(context) ?? settingsState.locale,
            builder: DevicePreview.appBuilder,

            // Localization
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Saliena Design System - Minimal Flat Theme
            theme: SalienaTheme.light,
            darkTheme: SalienaTheme.dark,
            themeMode: settingsState.themeMode,
          );
        },
      ),
    );
  }
}
