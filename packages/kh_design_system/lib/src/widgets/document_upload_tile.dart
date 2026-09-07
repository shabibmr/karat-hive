import 'package:flutter/material.dart';

enum UploadTileState { empty, uploading, uploaded, failed }

/// SH-MED-04 — one KYC document slot: pick, progress, replace.
class DocumentUploadTile extends StatelessWidget {
  const DocumentUploadTile({
    super.key,
    required this.label,
    required this.state,
    required this.onPick,
    this.progress = 0,
    this.errorText,
    this.addLabel = 'Add',
    this.replaceLabel = 'Replace',
    this.retryLabel = 'Retry',
  });

  final String label;
  final UploadTileState state;
  final VoidCallback onPick;
  final double progress;
  final String? errorText;
  final String addLabel;
  final String replaceLabel;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final (icon, trailing) = switch (state) {
      UploadTileState.empty => (Icons.upload_file, Text(addLabel)),
      UploadTileState.uploading => (
          Icons.hourglass_top,
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: progress == 0 ? null : progress,
            ),
          ),
        ),
      UploadTileState.uploaded => (Icons.check_circle, Text(replaceLabel)),
      UploadTileState.failed => (Icons.error_outline, Text(retryLabel)),
    };
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: errorText == null ? null : Text(errorText!),
        trailing: TextButton(
          onPressed: state == UploadTileState.uploading ? null : onPick,
          child: trailing,
        ),
      ),
    );
  }
}
