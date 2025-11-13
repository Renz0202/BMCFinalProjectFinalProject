import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// ProductImage
///
/// Displays a product image using a provided [imageUrl] when valid.
/// If not provided or invalid, it will pick a category-specific
/// placeholder image based on keywords in the [productName].
/// If loading or fetching fails, it shows a simple placeholder (no local asset).
class ProductImage extends StatelessWidget {
  final String productName;
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.productName,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  // We attempt to show the given imageUrl when valid; otherwise we render
  // a small neutral placeholder (no local asset fallback).

  Widget _placeholderBox() {
    final box = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: Colors.black12,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.black38,
      ),
    );
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: box);
    }
    return box;
  }

  Widget _buildNetwork(String url) {
    final image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => _placeholderBox(),
      fadeInDuration: const Duration(milliseconds: 150),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  @override
  Widget build(BuildContext context) {
    // Show provided remote image if valid.
    if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      return _buildNetwork(imageUrl);
    }
    // Fallback to neutral placeholder when no valid image url.
    return _placeholderBox();
  }
}
