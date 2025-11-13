import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/widgets/product_image.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> initialData;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.initialData,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  late final TextEditingController _imageController;
  late final TextEditingController _externalController;
  late final TextEditingController _brandController;
  late final TextEditingController _categoryController;
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _imageController = TextEditingController(
      text: (d['imageUrl'] as String?) ?? '',
    );
    _externalController = TextEditingController(
      text: (d['externalUrl'] as String?) ?? '',
    );
    _brandController = TextEditingController(
      text: (d['brand'] as String?) ?? '',
    );
    _categoryController = TextEditingController(
      text: (d['category'] as String?) ?? '',
    );
    _nameController = TextEditingController(text: (d['name'] as String?) ?? '');
    _descController = TextEditingController(
      text: (d['description'] as String?) ?? '',
    );
    _priceController = TextEditingController(
      text: ((d['price'] as num?)?.toString()) ?? '0.0',
    );
  }

  @override
  void dispose() {
    _imageController.dispose();
    _externalController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _firestore.collection('products').doc(widget.productId).update({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'imageUrl': _imageController.text.trim(),
        'externalUrl': _externalController.text.trim(),
        'brand': _brandController.text.trim(),
        'category': _categoryController.text.trim(),
      });
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Product updated')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_imageController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ProductImage(
                      productName: _nameController.text,
                      imageUrl: _imageController.text,
                      height: 180,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                    hintText: 'https://...',
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (!v.startsWith('http')) {
                      return 'Must start with http/https';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _externalController,
                  decoration: const InputDecoration(
                    labelText: 'External Product URL (optional)',
                    hintText: 'https://...',
                  ),
                  keyboardType: TextInputType.url,
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (!v.startsWith('http')) {
                      return 'Must start with http/https';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter description' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a price';
                    final parsed = double.tryParse(v);
                    if (parsed == null) return 'Enter a valid number';
                    if (parsed < 0) return 'Price cannot be negative';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
