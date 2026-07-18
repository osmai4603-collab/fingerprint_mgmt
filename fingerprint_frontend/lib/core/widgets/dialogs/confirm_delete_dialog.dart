import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? confirmText;
  final String? cancelText;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return AlertDialog(
      backgroundColor: errorColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          content,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: errorColor,
            textStyle: TextTheme.of(
              context,
            ).bodyLarge?.copyWith(fontWeight: .bold),
          ),
          child: Text(confirmText ?? AppLocalizations.of(context)!.confirm),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText ?? AppLocalizations.of(context)!.cancel,
            style: TextTheme.of(context).labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.errorContainer,
              fontWeight: .bold,
            ),
          ),
        ),
      ],
    );
  }
}
