import 'package:flutter/cupertino.dart';

/// Shows an iOS-style confirmation sheet (matching Apple's system alert
/// look) and returns `true` only if the destructive action was confirmed.
///
/// Used to guard actions a user could trigger by an accidental tap — e.g.
/// signing out — with a lightweight "are you sure?" step.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Confirm',
  bool destructive = true,
}) async {
  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: destructive
              ? CupertinoColors.systemRed
              : CupertinoColors.label,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(message),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
