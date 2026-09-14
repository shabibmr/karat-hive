import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import '../../kh_design_system.dart';

/// One image plus the content type it was uploaded as. AVIF renders through
/// `flutter_avif` (libavif) rather than Flutter's built-in image codecs,
/// which do not reliably decode AVIF across platforms; other formats use
/// the platform's native `Image.network`.
class GalleryImage {
  const GalleryImage({required this.url, this.contentType = 'image/jpeg'});

  final String url;
  final String contentType;
}

/// SH-MED-03 — Image gallery with thumbnail strip and tap-to-expand.
class KhImageGallery extends StatefulWidget {
  const KhImageGallery({
    super.key,
    required this.images,
    this.height = 220,
    this.onImageTap,
  });

  final List<GalleryImage> images;
  final double height;
  final void Function(int index)? onImageTap;

  @override
  State<KhImageGallery> createState() => _KhImageGalleryState();
}

class _KhImageGalleryState extends State<KhImageGallery> {
  int _selectedIndex = 0;

  Widget _networkImage(
    GalleryImage image, {
    required BoxFit fit,
    required Widget Function(BuildContext, Object, StackTrace?) errorBuilder,
  }) {
    if (image.contentType == 'image/avif') {
      return AvifImage.network(image.url, fit: fit, errorBuilder: errorBuilder);
    }
    return Image.network(
      image.url,
      fit: fit,
      errorBuilder: errorBuilder,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (widget.images.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: tokens.ink.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(tokens.radius.md),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported_outlined, size: 32, color: tokens.ink.withValues(alpha: 0.4)),
              const SizedBox(height: 6),
              Text(
                'No images attached',
                style: TextStyle(fontSize: 12, color: tokens.ink.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main selected image preview
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius.md),
          child: GestureDetector(
            onTap: () => widget.onImageTap?.call(_selectedIndex),
            child: Container(
              height: widget.height,
              width: double.infinity,
              color: tokens.ink.withValues(alpha: 0.06),
              child: _networkImage(
                widget.images[_selectedIndex],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.broken_image_outlined, size: 40, color: tokens.ink.withValues(alpha: 0.4)),
                ),
              ),
            ),
          ),
        ),
        if (widget.images.length > 1) ...[
          SizedBox(height: tokens.space.sm),
          // Thumbnails row
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              separatorBuilder: (_, __) => SizedBox(width: tokens.space.sm),
              itemBuilder: (context, idx) {
                final isSelected = idx == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = idx),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                      border: Border.all(
                        color: isSelected ? tokens.gold : tokens.ink.withValues(alpha: 0.15),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(tokens.radius.sm - 1),
                      child: _networkImage(
                        widget.images[idx],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.image, size: 20, color: tokens.ink.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
