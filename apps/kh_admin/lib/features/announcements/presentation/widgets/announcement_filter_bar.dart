import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/announcement_filters.dart';

/// Filter toolbar for the announcements list. Was `_AnnouncementFilterBar`
/// (TR-S2-08).
class AnnouncementFilterBar extends StatelessWidget {
  const AnnouncementFilterBar({
    super.key,
    required this.filters,
    required this.searchController,
    required this.onStatusChanged,
    required this.onAudienceChanged,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
  });

  final AnnouncementFilters filters;
  final TextEditingController searchController;
  final ValueChanged<AnnouncementStatus?> onStatusChanged;
  final ValueChanged<AudienceType?> onAudienceChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Container(
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Wrap(
        spacing: kh.spacing.md,
        runSpacing: kh.spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Field
          SizedBox(
            width: 280,
            child: TextField(
              key: const Key('announcement-search-field'),
              controller: searchController,
              onChanged: onSearchChanged,
              onSubmitted: (_) => onSearchSubmitted(),
              decoration: InputDecoration(
                hintText: 'Search announcements...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          // Status Dropdown
          DropdownButton<AnnouncementStatus?>(
            key: const Key('announcement-status-filter'),
            value: filters.status,
            hint: const Text('All Statuses'),
            items: [
              const DropdownMenuItem<AnnouncementStatus?>(
                value: null,
                child: Text('All Statuses'),
              ),
              ...AnnouncementStatus.values.map(
                (s) => DropdownMenuItem<AnnouncementStatus?>(
                  value: s,
                  child: Text(s.label),
                ),
              ),
            ],
            onChanged: onStatusChanged,
          ),
          // Audience Dropdown
          DropdownButton<AudienceType?>(
            key: const Key('announcement-audience-filter'),
            value: filters.audienceType,
            hint: const Text('All Audiences'),
            items: [
              const DropdownMenuItem<AudienceType?>(
                value: null,
                child: Text('All Audiences'),
              ),
              ...AudienceType.values.map(
                (a) => DropdownMenuItem<AudienceType?>(
                  value: a,
                  child: Text(a.label),
                ),
              ),
            ],
            onChanged: onAudienceChanged,
          ),
        ],
      ),
    );
  }
}
