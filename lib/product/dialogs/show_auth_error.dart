import 'package:auth_with_bloc/features/register/register.dart';
import 'package:auth_with_bloc/product/l10n/l10n.dart';
import 'package:flutter/material.dart' show BuildContext;

import 'generic_dialog.dart';

/// [showAuthError] shows an error dialog based on the [AuthError]
Future<void> showAuthError({
  required AuthError authError,
  required BuildContext context,
}) {
  final errorData = parseAuthErrorTextsFromCode(
    code: authError.code,
    l10n: context.l10n,
  );
  return showGenericDialog<void>(
    context: context,
    title: errorData.key,
    content: errorData.value,
    optionsBuilder: () => {
      context.l10n.close: true,
    },
  );
}
