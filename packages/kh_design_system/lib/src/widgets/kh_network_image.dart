import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';

/// Network image that routes AVIF through `flutter_avif` (libavif).
/// Flutter's built-in codecs do not reliably decode AVIF across platforms.
class KhNetworkImage extends StatelessWidget {
  const KhNetworkImage({
    super.key,
    required this.url,
    this.contentType = 'image/jpeg',
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  final String url;
  final String contentType;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  bool get _isAvif =>
      contentType == 'image/avif' || url.toLowerCase().contains('.avif');

  @override
  Widget build(BuildContext context) {
    final onError = errorBuilder ??
        (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined));

    if (_isAvif) {
      return AvifImage.network(
        url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: onError,
      );
    }

    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: onError,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }
}
