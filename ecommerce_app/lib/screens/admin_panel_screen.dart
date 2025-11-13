import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/product_utils.dart';
import 'package:ecommerce_app/widgets/product_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ecommerce_app/screens/edit_product_screen.dart';
import 'package:ecommerce_app/widgets/admin_gate.dart';
import 'package:ecommerce_app/screens/admin_order_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _externalUrlController = TextEditingController();
  final _brandInputController = TextEditingController();
  final _categoryInputController = TextEditingController();

  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _externalUrlController.dispose();
    _brandInputController.dispose();
    _categoryInputController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  Future<void> _confirmDeleteProduct(String productId) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text(
          'Are you sure you want to delete this product? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => navigator.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _firestore.collection('products').doc(productId).delete();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Product deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final imageUrl = _imageUrlController.text.trim();
      final externalUrl = _externalUrlController.text.trim();
      final brandInput = _brandInputController.text.trim();
      final categoryInput = _categoryInputController.text.trim();

      final derived = ProductUtils.deriveFields(
        name: name,
        description: description,
      );

      final payload = <String, dynamic>{
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl, // optional and may be empty
        'externalUrl': externalUrl, // optional and may be empty
        'brand': brandInput.isNotEmpty ? brandInput : derived['brand'],
        'category': categoryInput.isNotEmpty
            ? categoryInput
            : derived['category'],
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('products').add(payload);

      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Product uploaded')));
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      _externalUrlController.clear();
      _brandInputController.clear();
      _categoryInputController.clear();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showEditProductDialog(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProductScreen(productId: doc.id, initialData: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          actions: [
            IconButton(
              tooltip: 'Manage Orders',
              icon: const Icon(Icons.receipt_long),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminOrderScreen()),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Product',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _brandInputController,
                    decoration: const InputDecoration(
                      labelText: 'Brand (optional)',
                      hintText: 'e.g., Yamaha, RCF, TT Audio, JBL, Lumos, RMB',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoryInputController,
                    decoration: const InputDecoration(
                      labelText: 'Category (optional)',
                      hintText: 'e.g., Mixer, Microphone, Speaker, Moving Head',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a description'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL (optional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _externalUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Source/External URL (optional)',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isLoading ? null : _uploadProduct,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Upload Product'),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  Text(
                    'Products',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('products')
                        .orderBy('createdAt', descending: true)
                        .limit(100)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No products yet.'),
                        );
                      }

                      final docs = snapshot.data!.docs;
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final d = docs[index];
                          final data = d.data() as Map<String, dynamic>;
                          final name = (data['name'] as String?) ?? 'Unnamed';
                          final price =
                              (data['price'] as num?)?.toDouble() ?? 0.0;
                          final imageUrl = (data['imageUrl'] as String?) ?? '';
                          final category = (data['category'] as String?) ?? '';
                          final externalUrl =
                              (data['externalUrl'] as String?) ?? '';

                          return Card(
                            child: ListTile(
                              leading: ProductImage(
                                productName: name,
                                imageUrl: imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              title: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                category.isNotEmpty
                                    ? '₱${price.toStringAsFixed(2)} • $category'
                                    : '₱${price.toStringAsFixed(2)}',
                              ),
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  if (externalUrl.isNotEmpty)
                                    IconButton(
                                      tooltip: 'Open source page',
                                      icon: const Icon(Icons.open_in_new),
                                      onPressed: () => _openUrl(externalUrl),
                                    ),
                                  IconButton(
                                    tooltip: 'Duplicate',
                                    icon: const Icon(Icons.copy_all_outlined),
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      try {
                                        final dataMap =
                                            Map<String, dynamic>.from(data);
                                        dataMap['createdAt'] =
                                            FieldValue.serverTimestamp();
                                        final String baseName =
                                            (dataMap['name'] as String? ??
                                                    'Unnamed')
                                                .trim();
                                        dataMap['name'] = baseName.isEmpty
                                            ? 'Copied Product'
                                            : '$baseName (Copy)';
                                        final derivedCopy =
                                            ProductUtils.deriveFields(
                                              name: dataMap['name'] as String,
                                              description:
                                                  dataMap['description']
                                                      as String? ??
                                                  '',
                                            );
                                        dataMap['category'] =
                                            derivedCopy['category'];
                                        dataMap['brand'] = derivedCopy['brand'];
                                        await _firestore
                                            .collection('products')
                                            .add(dataMap);
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text('Product duplicated'),
                                          ),
                                        );
                                      } catch (e) {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to duplicate: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Edit',
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _showEditProductDialog(d),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () =>
                                        _confirmDeleteProduct(d.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
