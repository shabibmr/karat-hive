import 'package:flutter/material.dart';

/// SH-SET-01 — Language picker tile with EN/AR segmented button (`FR-VEN-025`, `FR-CUS-031`).
class LanguagePickerTile extends StatelessWidget {
  const LanguagePickerTile({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final String currentLocale;
  final ValueChanged<String> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.language),
        title: const Text('App Language'),
        subtitle: Text(
          currentLocale == 'ar' ? 'العربية (Arabic - RTL)' : 'English (LTR)',
        ),
        trailing: SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'en', label: Text('EN')),
            ButtonSegment(value: 'ar', label: Text('عربي')),
          ],
          selected: {currentLocale == 'ar' ? 'ar' : 'en'},
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              onLocaleChanged(selection.first);
            }
          },
        ),
      ),
    );
  }
}
