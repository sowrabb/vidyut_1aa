import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import '../../app/tokens.dart';
import '../../app/layout/adaptive.dart';
// seller store accessed via providers
import 'models.dart';
// removed: old advanced custom fields editor
import 'widgets/simple_custom_fields.dart';
import 'widgets/materials_selector.dart';
import '../../widgets/media_upload_widget.dart';
import '../../../app/provider_registry.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product; // null for new product, non-null for editing

  const ProductFormPage({super.key, this.product});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
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
  final List<String> _documents = <String>[]; // document URLs

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _loadProductData();
    }
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
    _documents
      ..clear()
      ..addAll(product.documents);
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
                  const SizedBox(height: 16),

                  // Category and Status
                  ResponsiveRow(
                    children: [
                      DropdownButtonFormField<String>(
                        value: (widget.product?.category.isNotEmpty ?? false)
                            ? widget.product!.category
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                        ),
                        items: kCategories
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) {
                          // store locally in _customValues to include while saving
                          _customValues = {
                            ..._customValues,
                            '__category__': v ?? '',
                          };
                        },
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Please select a category'
                            : null,
                      ),
                      DropdownButtonFormField<ProductStatus>(
                        value: widget.product?.status ?? ProductStatus.draft,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: ProductStatus.active,
                              child: Text('Active')),
                          DropdownMenuItem(
                              value: ProductStatus.inactive,
                              child: Text('Inactive')),
                          DropdownMenuItem(
                              value: ProductStatus.pending,
                              child: Text('Pending')),
                          DropdownMenuItem(
                              value: ProductStatus.draft, child: Text('Draft')),
                          DropdownMenuItem(
                              value: ProductStatus.archived,
                              child: Text('Archived')),
                        ],
                        onChanged: (v) {
                          _customValues = {
                            ..._customValues,
                            '__status__': v?.name ?? ProductStatus.draft.name,
                          };
                        },
                      ),
                    ],
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
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
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
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
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

                  // Media Section
                  const _SectionHeader(
                    title: 'Media & Documents',
                    icon: Ionicons.images_outline,
                  ),
                  const SizedBox(height: 12),

                  MediaUploadWidget(
                    currentImages: _images,
                    currentDocuments: _documents,
                    onImagesChanged: (images) {
                      setState(() {
                        _images.clear();
                        _images.addAll(images);
                      });
                    },
                    onDocumentsChanged: (documents) {
                      setState(() {
                        _documents.clear();
                        _documents.addAll(documents);
                      });
                    },
                    maxImages: 5,
                    maxDocuments: 3,
                    showDocuments: true,
                    folder: 'products',
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
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveProduct({bool submitForApproval = false}) {
    if (!_formKey.currentState!.validate()) return;

    final store = ref.read(sellerStoreProvider);
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

    final chosenCategory = (_customValues['__category__'] as String?) ??
        (widget.product?.category ?? '');
    // Ignore chosen status; we auto-publish

    // Auto-publish: new uploads go live immediately
    final effectiveStatus = ProductStatus.active;

    final product = Product(
      id: widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      brand: _brandController.text,
      subtitle: _subtitleController.text,
      category: chosenCategory,
      description: _descriptionController.text,
      images: _images.isNotEmpty
          ? List<String>.from(_images)
          : (widget.product?.images ?? const <String>[]),
      documents: _documents.isNotEmpty
          ? List<String>.from(_documents)
          : (widget.product?.documents ?? const <String>[]),
      price: double.parse(_priceController.text),
      moq: int.parse(_moqController.text),
      gstRate: double.tryParse(_gstController.text) ?? 18.0,
      materials: materials,
      customValues: {
        ..._customValues,
        if (_simpleFields.isNotEmpty)
          'custom': {for (final e in _simpleFields) e.key: e.value},
      },
      status: effectiveStatus,
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
