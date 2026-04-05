import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:saliena_app/routing/routes.dart';

/// Splash screen with dark blue branding and auto-navigation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Minimum splash display time
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.go(Routes.home);
    } else {
      context.go(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SalienaColors.navy,
      body: Stack(
        children: [
          // Centered Logo with text
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Image.asset(
                'assets/icons/Saliena-Estate-logo.png',
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Bottom Right Chevrons (house icons stacked)
          Positioned(
            bottom: 60,
            right: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/House-SplashScreen-Icon.svg',
                  width: 40,
                  height: 40,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.3),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 4),
                SvgPicture.asset(
                  'assets/icons/House-SplashScreen-Icon.svg',
                  width: 40,
                  height: 40,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.5),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 4),
                SvgPicture.asset(
                  'assets/icons/House-SplashScreen-Icon.svg',
                  width: 40,
                  height: 40,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.7),
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
