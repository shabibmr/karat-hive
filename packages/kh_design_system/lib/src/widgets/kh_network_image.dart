import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Network image that routes AVIF through `flutter_avif` (libavif)
/// and all other formats (WebP, JPEG, PNG) through `cached_network_image`.
/// Flutter's built-in codecs do not reliably decode AVIF across platforms.
///
/// Backend media URLs are relative (`/v1/media/<key>`); each app sets
/// [urlResolver] once at bootstrap to resolve them against its API base URL.
class KhNetworkImage extends StatelessWidget {
  static String? Function(String url)? urlResolver;
  static BaseCacheManager? defaultCacheManager;

  /// [url] resolved through [urlResolver]; absolute URLs pass through.
  static String resolve(String url) {
    if (url.isEmpty ||
        url.startsWith('http://') ||
        url.startsWith('https://')) {
      return url;
    }
    return urlResolver?.call(url) ?? url;
  }

  const KhNetworkImage({
    super.key,
    required this.url,
    this.contentType = 'image/jpeg',
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
    this.cacheManager,
  });

  final String url;
  final String contentType;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;
  final BaseCacheManager? cacheManager;

  bool get _isAvif =>
      contentType == 'image/avif' || url.toLowerCase().contains('.avif');

  @override
  Widget build(BuildContext context) {
    final onError = errorBuilder ??
        (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined));
    final resolved = resolve(url);

    if (_isAvif) {
      return AvifImage.network(
        resolved,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: onError,
      );
    }

    return CachedNetworkImage(
      imageUrl: resolved,
      cacheManager: cacheManager ?? defaultCacheManager,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, _) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (context, url, error) => onError(context, error, null),
    );
  }
}
