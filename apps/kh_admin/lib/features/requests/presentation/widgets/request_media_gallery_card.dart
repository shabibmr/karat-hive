import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Uploaded media gallery card. Was `_buildMediaGalleryCard`.
class RequestMediaGalleryCard extends StatelessWidget {
  const RequestMediaGalleryCard({super.key, required this.detail});

  final RequestDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const Key('request-media-gallery'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhSectionLabel(l10n?.requestsDetailMediaTitle(detail.media.length) ??
              'Uploaded Media (${detail.media.length})'),
          SizedBox(height: kh.spacing.md),
          if (detail.media.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Text(
                l10n?.requestsDetailNoMedia ??
                    'No media uploaded for this request.',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textMuted,
                  fontSize: 13.0,
                ),
              ),
            )
          else
            Wrap(
              spacing: kh.spacing.md,
              runSpacing: kh.spacing.md,
              children: [
                for (final item in detail.media)
                  Container(
                    width: 140.0,
                    padding: EdgeInsets.all(kh.spacing.xs),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundSurface,
                      borderRadius: kh.shapes.roundedMd,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: kh.colors.sapphire900,
                            borderRadius: kh.shapes.roundedSm,
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            color: kh.colors.goldPrimary,
                            size: 36.0,
                          ),
                        ),
                        SizedBox(height: kh.spacing.xxs),
                        Text(
                          item.fileName ??
                              (l10n?.requestsDetailImageNumber(
                                      item.displayOrder + 1) ??
                                  'Image #${item.displayOrder + 1}'),
                          style: kh.typography.caption.copyWith(
                            color: kh.colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.sizeBytes != null)
                          Text(
                            '${(item.sizeBytes! / 1024).toStringAsFixed(0)} KB',
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.textMuted,
                              fontSize: 10.0,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
