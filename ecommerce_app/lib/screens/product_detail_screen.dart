import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/widgets/product_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productData,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Quantity state
  int _quantity = 1;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract data for easier use
    final String name = widget.productData['name'] as String? ?? 'Unnamed';
    final String description =
        widget.productData['description'] as String? ?? '';
    final String imageUrl = widget.productData['imageUrl'] as String? ?? '';
    final double price =
        (widget.productData['price'] as num?)?.toDouble() ?? 0.0;
    final String category = widget.productData['category'] as String? ?? '';
    final String brand = widget.productData['brand'] as String? ?? '';
    final String externalUrl =
        widget.productData['externalUrl'] as String? ?? '';
    // Get the CartProvider (no rebuilds needed for this screen on cart updates)
    final cart = Provider.of<CartProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final horizontalPad = isCompact ? 12.0 : 16.0;
          final imageHeight = isCompact ? 220.0 : 300.0;
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProductImage(
                      productName: name,
                      imageUrl: imageUrl,
                      height: imageHeight,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPad,
                        16,
                        horizontalPad,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (brand.isNotEmpty || category.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (brand.isNotEmpty)
                                  Chip(
                                    label: Text(brand),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                if (category.isNotEmpty)
                                  Chip(
                                    label: Text(category),
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            '₱${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(thickness: 1),
                          const SizedBox(height: 16),
                          if (externalUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final uri = Uri.tryParse(externalUrl);
                                  if (uri != null) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('View Product Page'),
                              ),
                            ),
                          Text(
                            'About this item',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton.filledTonal(
                                icon: const Icon(Icons.remove),
                                onPressed: _decrementQuantity,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton.filled(
                                icon: const Icon(Icons.add),
                                onPressed: _incrementQuantity,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: isCompact ? 48 : 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                cart.addItem(
                                  widget.productId,
                                  name,
                                  price,
                                  _quantity,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added $_quantity x $name to cart!',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.shopping_cart_outlined),
                              label: const Text('Add to Cart'),
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
