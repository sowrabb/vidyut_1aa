import 'package:flutter/material.dart';
import '../../../widgets/image_upload_widget.dart';
import '../models/hero_section.dart';

class HeroSectionEditor extends StatefulWidget {
  final HeroSection? hero;
  final Function(HeroSection) onSave;

  const HeroSectionEditor({
    super.key,
    this.hero,
    required this.onSave,
  });

  @override
  State<HeroSectionEditor> createState() => _HeroSectionEditorState();
}

class _HeroSectionEditorState extends State<HeroSectionEditor> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _ctaTextController = TextEditingController();
  final _ctaUrlController = TextEditingController();

  String? _imagePath; // uploaded image path
  bool _isActive = true;
  int _priority = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.hero != null) {
      _titleController.text = widget.hero!.title;
      _subtitleController.text = widget.hero!.subtitle;
      _ctaTextController.text = widget.hero!.ctaText ?? '';
      _ctaUrlController.text = widget.hero!.ctaUrl ?? '';
      _imagePath = widget.hero!.imagePath;
      _isActive = widget.hero!.isActive;
      _priority = widget.hero!.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _ctaTextController.dispose();
    _ctaUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.slideshow,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.hero != null
                      ? 'Edit Hero Section'
                      : 'Add Hero Section',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildSectionHeader('Basic Information'),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title * (Max 60 characters)',
                          hintText: 'Enter hero section title',
                          border: const OutlineInputBorder(),
                          counterText: '${_titleController.text.length}/60',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          if (value.length > 60) {
                            return 'Title must be 60 characters or less for mobile visibility';
                          }
                          return null;
                        },
                        maxLines: 2,
                        maxLength: 60,
                        onChanged: (value) {
                          setState(() {}); // Update counter
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _subtitleController,
                        decoration: InputDecoration(
                          labelText: 'Subtitle * (Max 40 characters)',
                          hintText: 'Enter hero section subtitle',
                          border: const OutlineInputBorder(),
                          counterText: '${_subtitleController.text.length}/40',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Subtitle is required';
                          }
                          if (value.length > 40) {
                            return 'Subtitle must be 40 characters or less for mobile visibility';
                          }
                          return null;
                        },
                        maxLines: 3,
                        maxLength: 40,
                        onChanged: (value) {
                          setState(() {}); // Update counter
                        },
                      ),
                      const SizedBox(height: 24),

                      // CTA Section
                      _buildSectionHeader('Call to Action (Optional)'),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ctaTextController,
                              decoration: InputDecoration(
                                labelText: 'CTA Text (Max 20 chars)',
                                hintText: 'e.g., "Explore Now", "Get Started"',
                                border: const OutlineInputBorder(),
                                counterText:
                                    '${_ctaTextController.text.length}/20',
                              ),
                              maxLength: 20,
                              onChanged: (value) {
                                setState(() {}); // Update counter
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _ctaUrlController,
                              decoration: const InputDecoration(
                                labelText: 'CTA URL',
                                hintText: '/products, /search, etc.',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Image Upload Section
                      _buildSectionHeader('Hero Image'),
                      const SizedBox(height: 16),

                      _buildImageUploadSection(),
                      const SizedBox(height: 24),

                      // Settings
                      _buildSectionHeader('Settings'),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _priority.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Priority',
                                hintText: 'Lower number = higher priority',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                _priority = int.tryParse(value) ?? 0;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Active'),
                              subtitle: const Text('Show on homepage'),
                              value: _isActive,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: _isLoading ? null : _saveHeroSection,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.hero != null ? 'Update' : 'Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
    );
  }

  Widget _buildImageUploadSection() {
    return ImageUploadWidget(
      currentImagePath: _imagePath,
      onImageSelected: (result) {
        setState(() {
          _imagePath = result.path;
        });
      },
      onImageRemoved: (_) {
        setState(() {
          _imagePath = null;
        });
      },
      width: double.infinity,
      height: 200,
      label: 'Hero Image',
      hint: 'Supported formats: JPG, PNG, GIF, WebP. Maximum file size: 5MB.',
      showPreview: true,
      allowMultipleSources: true,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Future<void> _saveHeroSection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final formData = HeroSectionFormData(
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim(),
        ctaText: _ctaTextController.text.trim().isEmpty
            ? null
            : _ctaTextController.text.trim(),
        ctaUrl: _ctaUrlController.text.trim().isEmpty
            ? null
            : _ctaUrlController.text.trim(),
        imagePath: _imagePath, // For file-based platforms
        priority: _priority,
        isActive: _isActive,
      );

      // Note: For web, persist bytes to backend/storage; for now we keep it in-memory

      final heroSection = formData.toHeroSection(
        id: widget.hero?.id,
      );

      widget.onSave(heroSection);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.hero != null
                  ? 'Hero section updated successfully'
                  : 'Hero section created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving hero section: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
