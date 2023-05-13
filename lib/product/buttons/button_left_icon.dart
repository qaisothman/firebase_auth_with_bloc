import 'package:auth_with_bloc/product/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ButtonColor { primary, white }

class ButtonWithLeftIcon extends StatelessWidget {
  const ButtonWithLeftIcon.large({
    super.key,
    this.onPressed,
    this.text,
    this.icon,
    this.padding,
    this.alignment,
    this.color,
    this.buttonDefaultColor = ButtonColor.primary,
    this.borderColor,
    this.width = double.infinity,
    this.height = 52,
  });
  const ButtonWithLeftIcon.small({
    super.key,
    this.onPressed,
    this.text,
    this.icon,
    this.padding,
    this.alignment,
    this.color,
    this.buttonDefaultColor = ButtonColor.primary,
    this.borderColor,
    this.width = 120,
    this.height = 52,
  });

  final VoidCallback? onPressed;
  final String? text;
  final Widget? icon;
  final EdgeInsets? padding;
  final MainAxisAlignment? alignment;
  final double? width;
  final double? height;
  final Color? color;
  final ButtonColor buttonDefaultColor;
  final Color? borderColor;

  bool get isPrimary => buttonDefaultColor == ButtonColor.primary;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
    );

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w),
      child: SizedBox.fromSize(
        size: Size((width ?? double.infinity).w, (height ?? 52).h),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor ?? color ?? context.theme.colorScheme.primary,
              strokeAlign: BorderSide.strokeAlignCenter,
            ),
            borderRadius: BorderRadius.circular(100.w),
          ),
          child: PlatformElevatedButton(
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            color: color ??
                (isPrimary
                    ? context.theme.colorScheme.primary
                    : context.theme.colorScheme.background),
            material: (context, __) => MaterialElevatedButtonData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.w),
                ),
                side: BorderSide(
                  color:
                      borderColor ?? color ?? context.theme.colorScheme.primary,
                ),
                backgroundColor: color ??
                    (isPrimary
                        ? context.theme.colorScheme.primary
                        : context.theme.colorScheme.background),
              ),
            ),
            cupertino: (_, __) => CupertinoElevatedButtonData(
              borderRadius: BorderRadius.circular(100.w),
            ),
            child: Row(
              mainAxisAlignment: alignment ?? MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, SizedBox(width: 8.w)],
                if (text != null)
                  Flexible(
                    child: Text(
                      text!,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: isPrimary
                            ? context.theme.colorScheme.onPrimary
                            : context.theme.colorScheme.kMedEmphasis,
                      ),
                      overflow: TextOverflow.fade,
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
