import 'package:flutter/material.dart';
import 'package:ecommerce_app/widgets/product_image.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final double price;
  final String imageUrl;
  final String? category;
  final String? brand;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
    required this.imageUrl,
    this.category,
    this.brand,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use a Card that relies on the global CardTheme (rounded corners + clip)
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image takes 3 parts of the available space
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ProductImage(
                      productName: productName,
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if ((category != null && category!.isNotEmpty) ||
                      (brand != null && brand!.isNotEmpty))
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          [brand, category]
                              .whereType<String>()
                              .where((e) => e.isNotEmpty)
                              .join(' • '),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Text area takes 2 parts
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '₱${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
