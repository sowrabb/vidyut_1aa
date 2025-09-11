import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ionicons/ionicons.dart';
import '../../app/tokens.dart';
import '../../app/layout/adaptive.dart';
import 'store/seller_store.dart';
import 'models.dart';
// removed: old advanced custom fields editor
import 'widgets/simple_custom_fields.dart';
import 'widgets/materials_selector.dart';
import '../../widgets/optimized_image_widget.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product; // null for new product, non-null for editing

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _brandController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _moqController = TextEditingController();
  final _gstController = TextEditingController();
  final _materialsController = TextEditingController();
  List<String> _materials = [];

  Map<String, dynamic> _customValues = {};
  List<MapEntry<String, String>> _simpleFields = [];
  final List<String> _images = <String>[]; // local paths or URLs
  // Image picker temporarily disabled for web deployment

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _loadProductData();
    }
    // Add listeners for auto-save
    _addTextControllerListeners();
  }

  void _addTextControllerListeners() {
    _titleController.addListener(_autoSave);
    _brandController.addListener(_autoSave);
    _subtitleController.addListener(_autoSave);
    _descriptionController.addListener(_autoSave);
    _priceController.addListener(_autoSave);
    _moqController.addListener(_autoSave);
    _gstController.addListener(_autoSave);
    _materialsController.addListener(_autoSave);
  }

  void _autoSave() {
    // Auto-save form data to prevent loss
    _saveFormState();
  }

  void _saveFormState() {
    // Save form state to local storage
    // This would typically use SharedPreferences or similar
    // For now, we'll just store in memory
  }

  void _loadProductData() {
    final product = widget.product!;
    _titleController.text = product.title;
    _brandController.text = product.brand;
    _subtitleController.text = product.subtitle;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _moqController.text = product.moq.toString();
    _gstController.text = product.gstRate.toString();
    _materialsController.text = product.materials.join(', ');
    _materials = List.of(product.materials);
    _customValues = Map.from(product.customValues);
    _images
      ..clear()
      ..addAll(product.images.take(5));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _moqController.dispose();
    _gstController.dispose();
    _materialsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          TextButton(
            onPressed: _saveProduct,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: ContentClamp(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basics Section
                  const _SectionHeader(
                    title: 'Basic Information',
                    icon: Ionicons.information_circle_outline,
                  ),
                  const SizedBox(height: 16),

                  ResponsiveRow(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Product Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          if (value.length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          if (value.length > 100) {
                            return 'Title must be less than 100 characters';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                          labelText: 'Brand *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a brand';
                          }
                          if (value.length < 2) {
                            return 'Brand must be at least 2 characters';
                          }
                          if (value.length > 50) {
                            return 'Brand must be less than 50 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _subtitleController,
                    decoration: const InputDecoration(
                      labelText: 'Subtitle',
                      hintText: 'e.g., PVC | 1.5 sqmm | 1100V',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pricing Section
                  const _SectionHeader(
                    title: 'Pricing & Quantity',
                    icon: Ionicons.pricetag_outline,
                  ),
                  const SizedBox(height: 16),

                  ResponsiveRow(
                    desktop: 3,
                    tablet: 2,
                    phone: 1,
                    children: [
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (₹) *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          final price = double.tryParse(value);
                          if (price == null) {
                            return 'Please enter a valid number';
                          }
                          if (price <= 0) {
                            return 'Price must be greater than 0';
                          }
                          if (price > 10000000) {
                            return 'Price must be less than ₹1 crore';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _moqController,
                        decoration: const InputDecoration(
                          labelText: 'Minimum Order Quantity *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter MOQ';
                          }
                          final moq = int.tryParse(value);
                          if (moq == null) {
                            return 'Please enter a valid number';
                          }
                          if (moq <= 0) {
                            return 'MOQ must be greater than 0';
                          }
                          if (moq > 1000000) {
                            return 'MOQ must be less than 1 million';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _gstController,
                        decoration: const InputDecoration(
                          labelText: 'GST Rate (%)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  const _SectionHeader(
                    title: 'Description',
                    icon: Ionicons.document_text_outline,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Product Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // Materials Section
                  const _SectionHeader(
                    title: 'Materials',
                    icon: Ionicons.cube_outline,
                  ),
                  const SizedBox(height: 16),

                  MaterialsSelector(
                    value: _materials,
                    onChanged: (v) {
                      setState(() => _materials = v);
                      _materialsController.text = v.join(', ');
                    },
                  ),
                  const SizedBox(height: 24),

                  // Custom Fields Section (simple title + content)
                  const _SectionHeader(
                    title: 'Custom Fields',
                    icon: Ionicons.add_circle_outline,
                  ),
                  const SizedBox(height: 16),
                  SimpleCustomFields(
                    entries: _simpleFields,
                    onChanged: (v) => setState(() => _simpleFields = v),
                  ),
                  const SizedBox(height: 32),

                  // Images Section
                  const _SectionHeader(
                    title: 'Images (max 5)',
                    icon: Ionicons.images_outline,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _onPickFromGallery,
                        icon: const Icon(Ionicons.image_outline),
                        label: const Text('Add Photos'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _onCaptureFromCamera,
                        icon: const Icon(Ionicons.camera_outline),
                        label: const Text('Take Photo'),
                      ),
                      const Spacer(),
                      if (_images.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => setState(_images.clear),
                          icon: const Icon(Ionicons.trash_outline),
                          label: const Text('Clear All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ImagesGrid(
                    images: _images,
                    onRemove: _removeImageAt,
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saveProduct,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.product == null
                            ? 'Create Product'
                            : 'Update Product',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final store = Provider.of<SellerStore>(context, listen: false);
    final materials = _materials.isNotEmpty
        ? _materials
        : _materialsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    if (_images.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can upload a maximum of 5 images')),
      );
      return;
    }

    final product = Product(
      id: widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      brand: _brandController.text,
      subtitle: _subtitleController.text,
      description: _descriptionController.text,
      images: _images.isNotEmpty
          ? List<String>.from(_images)
          : (widget.product?.images ?? const <String>[]),
      price: double.parse(_priceController.text),
      moq: int.parse(_moqController.text),
      gstRate: double.tryParse(_gstController.text) ?? 18.0,
      materials: materials,
      customValues: {
        ..._customValues,
        if (_simpleFields.isNotEmpty)
          'custom': {for (final e in _simpleFields) e.key: e.value},
      },
    );

    if (widget.product == null) {
      store.addProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product created successfully')),
      );
    } else {
      store.updateProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
    }

    Navigator.of(context).pop();
  }

  Future<void> _onPickFromGallery() async {
    try {
      final remaining = 5 - _images.length;
      if (remaining <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 5 images allowed')),
        );
        return;
      }
      // Image picker temporarily disabled for web deployment
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image picker will be available after Firebase setup')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick images')),
      );
    }
  }

  Future<void> _onCaptureFromCamera() async {
    try {
      if (_images.length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 5 images allowed')),
        );
        return;
      }
      // Camera picker temporarily disabled for web deployment
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera will be available after Firebase setup')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture image')),
      );
    }
  }

  void _removeImageAt(int index) {
    setState(() {
      if (index >= 0 && index < _images.length) {
        _images.removeAt(index);
      }
    });
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _ImagesGrid extends StatelessWidget {
  final List<String> images;
  final void Function(int index) onRemove;

  const _ImagesGrid({required this.images, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 96,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineSoft),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('No images selected.')),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final path = images[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: OptimizedImageWidget(
                imagePath: path,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () => onRemove(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
