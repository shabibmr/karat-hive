import 'package:flutter/material.dart';
import '../../kh_design_system.dart';

/// SH-MED-03 — Image gallery with thumbnail strip and tap-to-expand.
class KhImageGallery extends StatefulWidget {
  const KhImageGallery({
    super.key,
    required this.imageUrls,
    this.height = 220,
    this.onImageTap,
  });

  final List<String> imageUrls;
  final double height;
  final void Function(int index)? onImageTap;

  @override
  State<KhImageGallery> createState() => _KhImageGalleryState();
}

class _KhImageGalleryState extends State<KhImageGallery> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (widget.imageUrls.isEmpty) {
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
              child: Image.network(
                widget.imageUrls[_selectedIndex],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.broken_image_outlined, size: 40, color: tokens.ink.withValues(alpha: 0.4)),
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
              ),
            ),
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          SizedBox(height: tokens.space.sm),
          // Thumbnails row
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imageUrls.length,
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
                      child: Image.network(
                        widget.imageUrls[idx],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image, size: 20, color: tokens.ink.withValues(alpha: 0.3)),
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
