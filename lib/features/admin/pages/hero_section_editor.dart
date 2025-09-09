import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/simple_image_service.dart';
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
  String? _imageError;

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
                  widget.hero != null ? 'Edit Hero Section' : 'Add Hero Section',
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
                                counterText: '${_ctaTextController.text.length}/20',
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

  Widget _buildImagePreview() {
    if (_imagePath!.startsWith('web_storage://')) {
      // For web storage, load from SharedPreferences
      return FutureBuilder<String?>(
        future: _loadWebImage(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              base64Decode(snapshot.data!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(height: 8),
                      Text('Error loading image'),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(height: 8),
                  Text('Error loading image'),
                ],
              ),
            );
          }
        },
      );
    } else {
      // For file system
      return Image.file(
        File(_imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(height: 8),
                Text('Error loading image'),
              ],
            ),
          );
        },
      );
    }
  }

  Future<String?> _loadWebImage() async {
    try {
      final fileName = _imagePath!.replaceFirst('web_storage://', '');
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('hero_image_$fileName');
    } catch (e) {
      return null;
    }
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image preview
        if (_imagePath != null) ...[
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImagePreview(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Upload buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImageFromFiles,
                icon: const Icon(Icons.folder_open),
                label: const Text('Files'),
              ),
            ),
          ],
        ),
        
        if (_imageError != null) ...[
          const SizedBox(height: 8),
          Text(
            _imageError!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
        
        const SizedBox(height: 8),
        Text(
          'Supported formats: JPG, PNG, GIF, WebP. Maximum file size: 10MB.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // We'll compress it ourselves
      );
      
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          await _processImageBytes(bytes);
        } else {
          await _processImage(image.path);
        }
      }
    } catch (e) {
      setState(() {
        _imageError = 'Error taking photo: $e';
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // We'll compress it ourselves
      );
      
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          await _processImageBytes(bytes);
        } else {
          await _processImage(image.path);
        }
      }
    } catch (e) {
      setState(() {
        _imageError = 'Error selecting image: $e';
      });
    }
  }

  Future<void> _pickImageFromFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // On web, path is null; use bytes
        if (file.bytes != null && (file.path == null || file.path!.isEmpty)) {
          await _processImageBytes(file.bytes!);
        } else if (file.path != null) {
          await _processImage(file.path!);
        }
      }
    } catch (e) {
      setState(() {
        _imageError = 'Error selecting file: $e';
      });
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() {
      _isLoading = true;
      _imageError = null;
    });

    try {
      final File imageFile = File(imagePath);
      
      // Validate image
      final isValid = await SimpleImageService.validateImageFile(imageFile);
      if (!isValid) {
        setState(() {
          _imageError = 'Invalid image file. Please select a valid image (JPG, PNG, GIF, WebP) under 10MB.';
          _isLoading = false;
        });
        return;
      }

      // Get original file size for comparison
      final originalSize = await SimpleImageService.getFileSizeKB(imagePath);
      
      // Upload image to uploads directory
      final String? uploadedPath = await SimpleImageService.uploadImageFile(imageFile);
      
      if (uploadedPath == null) {
        setState(() {
          _imageError = 'Failed to upload image. Please try again.';
          _isLoading = false;
        });
        return;
      }

      final uploadedSize = await SimpleImageService.getFileSizeKB(uploadedPath);
      
      setState(() {
        _imagePath = uploadedPath;
        _isLoading = false;
        _imageError = null;
      });

      // Show upload info
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image uploaded: ${SimpleImageService.formatFileSize(originalSize)} → ${SimpleImageService.formatFileSize(uploadedSize)}',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _imageError = 'Error processing image: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _processImageBytes(Uint8List bytes) async {
    setState(() {
      _isLoading = true;
      _imageError = null;
    });

    try {
      // Validate
      final valid = SimpleImageService.validateImageBytes(bytes);
      if (!valid) {
        setState(() {
          _imageError = 'Invalid image format or size. Please select a valid image under 10MB.';
          _isLoading = false;
        });
        return;
      }

      final originalSizeKB = bytes.length / 1024.0;
      
      // Determine file extension from bytes (simple check)
      String extension = 'jpg'; // default
      if (bytes.length >= 4) {
        if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
          extension = 'png';
        } else if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
          extension = 'gif';
        } else if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) {
          extension = 'webp';
        }
      }

      // Upload image bytes
      final String? uploadedPath = await SimpleImageService.uploadImageBytes(bytes, extension);
      
      if (uploadedPath == null) {
        setState(() {
          _imageError = 'Failed to upload image. Please try again.';
          _isLoading = false;
        });
        return;
      }

      final uploadedSize = await SimpleImageService.getFileSizeKB(uploadedPath);

      setState(() {
        _imagePath = uploadedPath; // Store the uploaded path
        _isLoading = false;
        _imageError = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image uploaded: ${SimpleImageService.formatFileSize(originalSizeKB)} → ${SimpleImageService.formatFileSize(uploadedSize)}',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _imageError = 'Error processing image: $e';
        _isLoading = false;
      });
    }
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
        ctaText: _ctaTextController.text.trim().isEmpty ? null : _ctaTextController.text.trim(),
        ctaUrl: _ctaUrlController.text.trim().isEmpty ? null : _ctaUrlController.text.trim(),
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
