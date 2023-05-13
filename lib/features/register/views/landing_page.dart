import 'dart:io';

import 'package:auth_with_bloc/features/register/auth/bloc/auth_bloc.dart';
import 'package:auth_with_bloc/product/buttons/button_left_icon.dart';
import 'package:auth_with_bloc/product/dialogs/show_auth_error.dart';
import 'package:auth_with_bloc/product/l10n/l10n.dart';
import 'package:auth_with_bloc/product/theme/theme_manager.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.theme.colorScheme;
    final l10n = context.l10n;
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
    );
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        final authError = state.authError;
        if (authError != null) {
          await showAuthError(
            authError: authError,
            context: context,
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                ),
                Text(
                  'HElo',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.kHighEmphasis,
                  ),
                ),
                ButtonWithLeftIcon.large(
                  onPressed: () {
                    debugPrint('need to set up a router configs!');
                  },
                  text: l10n.loginWithPhone,
                  icon: const Icon(FluentIcons.phone_20_filled),
                ),
                SizedBox(
                  height: 40,
                ),
                ButtonWithLeftIcon.large(
                  onPressed: () => context
                      .read<AuthBloc>()
                      .add(const AuthEventSignInWithGoogle()),
                  text: l10n.loginWithGoogle,
                  icon: FaIcon(
                    FontAwesomeIcons.google,
                    color: context.theme.colorScheme.primary,
                    size: 20,
                  ),
                  buttonDefaultColor: ButtonColor.white,
                ),
               SizedBox(
                  height: 40,
                ),
                if (Platform.isIOS)
                  ButtonWithLeftIcon.large(
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthEventSignInWithApple()),
                    text: l10n.loginWithApple,
                    icon: FaIcon(
                      FontAwesomeIcons.apple,
                      color: context.theme.colorScheme.primary,
                      size: 24,
                    ),
                    buttonDefaultColor: ButtonColor.white,
                  )
                else
                  const SizedBox.shrink(),
               SizedBox(
                  height: 40,
                ),
                PlatformTextButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    context
                        .read<AuthBloc>()
                        .add(const AuthEventSignInAnonymously());
                  },
                  child: Text(
                    l10n.loginAnonymously,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: colorScheme.kLowEmphasis,
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
}
