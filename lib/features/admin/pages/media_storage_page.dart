import 'package:flutter/material.dart';
import '../models/media_models.dart';

class MediaStoragePage extends StatefulWidget {
  const MediaStoragePage({super.key});

  @override
  State<MediaStoragePage> createState() => _MediaStoragePageState();
}

class _MediaStoragePageState extends State<MediaStoragePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media & Storage'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Files', icon: Icon(Icons.folder)),
            Tab(text: 'Uploads', icon: Icon(Icons.upload)),
            Tab(text: 'CDN', icon: Icon(Icons.cloud)),
            Tab(text: 'Cleanup', icon: Icon(Icons.cleaning_services)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MediaFilesTab(),
          MediaUploadsTab(),
          CDNVariantsTab(),
          MediaCleanupTab(),
        ],
      ),
    );
  }
}

class MediaFilesTab extends StatefulWidget {
  const MediaFilesTab({super.key});

  @override
  State<MediaFilesTab> createState() => _MediaFilesTabState();
}

class _MediaFilesTabState extends State<MediaFilesTab> {
  List<MediaFile> _mediaFiles = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  MediaFileType? _selectedType;
  MediaFileStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadMediaFiles();
  }

  Future<void> _loadMediaFiles() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Mock data for demonstration
      await Future.delayed(const Duration(seconds: 1));

      _mediaFiles = [
        MediaFile(
          id: '1',
          filename: 'hero_banner.jpg',
          originalFilename: 'hero_banner.jpg',
          mimeType: 'image/jpeg',
          fileSize: 245760,
          url: 'https://cdn.vidyut.com/images/hero_banner.jpg',
          thumbnailUrl:
              'https://cdn.vidyut.com/images/thumbnails/hero_banner.jpg',
          variants: {
            'small': 'https://cdn.vidyut.com/images/small/hero_banner.jpg',
            'medium': 'https://cdn.vidyut.com/images/medium/hero_banner.jpg',
            'large': 'https://cdn.vidyut.com/images/large/hero_banner.jpg',
          },
          type: MediaFileType.image,
          status: MediaFileStatus.processed,
          metadata: {
            'width': 1920,
            'height': 1080,
            'format': 'JPEG',
            'color_space': 'sRGB',
          },
          uploadedBy: 'admin@vidyut.com',
          uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        MediaFile(
          id: '2',
          filename: 'product_catalog.pdf',
          originalFilename: 'product_catalog.pdf',
          mimeType: 'application/pdf',
          fileSize: 2048576,
          url: 'https://cdn.vidyut.com/documents/product_catalog.pdf',
          variants: {},
          type: MediaFileType.document,
          status: MediaFileStatus.processed,
          metadata: {
            'pages': 45,
            'title': 'Product Catalog 2024',
            'author': 'Marketing Team',
          },
          uploadedBy: 'marketing@vidyut.com',
          uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        MediaFile(
          id: '3',
          filename: 'demo_video.mp4',
          originalFilename: 'demo_video.mp4',
          mimeType: 'video/mp4',
          fileSize: 52428800,
          url: 'https://cdn.vidyut.com/videos/demo_video.mp4',
          thumbnailUrl:
              'https://cdn.vidyut.com/videos/thumbnails/demo_video.jpg',
          variants: {
            '480p': 'https://cdn.vidyut.com/videos/480p/demo_video.mp4',
            '720p': 'https://cdn.vidyut.com/videos/720p/demo_video.mp4',
            '1080p': 'https://cdn.vidyut.com/videos/1080p/demo_video.mp4',
          },
          type: MediaFileType.video,
          status: MediaFileStatus.processing,
          metadata: {
            'duration': 120,
            'resolution': '1920x1080',
            'fps': 30,
            'codec': 'H.264',
          },
          uploadedBy: 'content@vidyut.com',
          uploadedAt: DateTime.now().subtract(const Duration(hours: 2)),
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  List<MediaFile> get _filteredFiles {
    var filtered = _mediaFiles;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((file) =>
              file.filename
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              file.originalFilename
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedType != null) {
      filtered = filtered.where((file) => file.type == _selectedType).toList();
    }

    if (_selectedStatus != null) {
      filtered =
          filtered.where((file) => file.status == _selectedStatus).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMediaFiles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search and Filter Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search media files...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _uploadMediaFile,
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  DropdownButton<MediaFileType?>(
                    value: _selectedType,
                    hint: const Text('All Types'),
                    items: [
                      const DropdownMenuItem<MediaFileType?>(
                        value: null,
                        child: Text('All Types'),
                      ),
                      ...MediaFileType.values.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.value.toUpperCase()),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<MediaFileStatus?>(
                    value: _selectedStatus,
                    hint: const Text('All Status'),
                    items: [
                      const DropdownMenuItem<MediaFileStatus?>(
                        value: null,
                        child: Text('All Status'),
                      ),
                      ...MediaFileStatus.values
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.value.toUpperCase()),
                              )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  const Spacer(),
                  Chip(
                    label: Text('${_filteredFiles.length} files'),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Media Files Grid
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadMediaFiles,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _filteredFiles.length,
              itemBuilder: (context, index) {
                final file = _filteredFiles[index];
                return _buildMediaFileCard(file);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaFileCard(MediaFile file) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: _buildThumbnail(file),
            ),
          ),

          // File Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.filename,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(file.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          file.status.value.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatFileSize(file.fileSize),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        _getTypeIcon(file.type),
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          file.type.value.toUpperCase(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleFileAction(file, value),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'download',
                            child: Row(
                              children: [
                                Icon(Icons.download, size: 16),
                                SizedBox(width: 8),
                                Text('Download'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'copy_url',
                            child: Row(
                              children: [
                                Icon(Icons.copy, size: 16),
                                SizedBox(width: 8),
                                Text('Copy URL'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'view_details',
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 16),
                                SizedBox(width: 8),
                                Text('View Details'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(MediaFile file) {
    switch (file.type) {
      case MediaFileType.image:
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          child: Image.network(
            file.thumbnailUrl ?? file.url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.image,
              size: 48,
              color: Colors.grey,
            ),
          ),
        );
      case MediaFileType.video:
        return Stack(
          alignment: Alignment.center,
          children: [
            if (file.thumbnailUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  file.thumbnailUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.videocam,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              const Icon(
                Icons.videocam,
                size: 48,
                color: Colors.grey,
              ),
            const CircleAvatar(
              backgroundColor: Colors.black54,
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ],
        );
      case MediaFileType.document:
        return const Center(
          child: Icon(
            Icons.description,
            size: 48,
            color: Colors.grey,
          ),
        );
      case MediaFileType.audio:
        return const Center(
          child: Icon(
            Icons.audiotrack,
            size: 48,
            color: Colors.grey,
          ),
        );
      case MediaFileType.archive:
        return const Center(
          child: Icon(
            Icons.archive,
            size: 48,
            color: Colors.grey,
          ),
        );
      case MediaFileType.other:
        return const Center(
          child: Icon(
            Icons.insert_drive_file,
            size: 48,
            color: Colors.grey,
          ),
        );
    }
  }

  IconData _getTypeIcon(MediaFileType type) {
    switch (type) {
      case MediaFileType.image:
        return Icons.image;
      case MediaFileType.video:
        return Icons.videocam;
      case MediaFileType.audio:
        return Icons.audiotrack;
      case MediaFileType.document:
        return Icons.description;
      case MediaFileType.archive:
        return Icons.archive;
      case MediaFileType.other:
        return Icons.insert_drive_file;
    }
  }

  Color _getStatusColor(MediaFileStatus status) {
    switch (status) {
      case MediaFileStatus.uploading:
        return Colors.blue;
      case MediaFileStatus.uploaded:
        return Colors.orange;
      case MediaFileStatus.processing:
        return Colors.amber;
      case MediaFileStatus.processed:
        return Colors.green;
      case MediaFileStatus.failed:
        return Colors.red;
      case MediaFileStatus.deleted:
        return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _uploadMediaFile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Media File'),
        content: const Text('File upload dialog - Coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleFileAction(MediaFile file, String action) {
    switch (action) {
      case 'download':
        _downloadFile(file);
        break;
      case 'copy_url':
        _copyUrl(file);
        break;
      case 'view_details':
        _viewFileDetails(file);
        break;
      case 'delete':
        _deleteFile(file);
        break;
    }
  }

  void _downloadFile(MediaFile file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${file.filename}...')),
    );
  }

  void _copyUrl(MediaFile file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('URL copied: ${file.url}')),
    );
  }

  void _viewFileDetails(MediaFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.filename),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Original Filename: ${file.originalFilename}'),
              Text('MIME Type: ${file.mimeType}'),
              Text('File Size: ${_formatFileSize(file.fileSize)}'),
              Text('Type: ${file.type.value}'),
              Text('Status: ${file.status.value}'),
              const SizedBox(height: 8),
              Text('URL: ${file.url}'),
              if (file.thumbnailUrl != null)
                Text('Thumbnail: ${file.thumbnailUrl}'),
              const SizedBox(height: 8),
              if (file.variants.isNotEmpty) ...[
                const Text('Variants:'),
                ...file.variants.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text('${entry.key}: ${entry.value}'),
                    )),
              ],
              const SizedBox(height: 8),
              if (file.metadata.isNotEmpty) ...[
                const Text('Metadata:'),
                ...file.metadata.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text('${entry.key}: ${entry.value}'),
                    )),
              ],
              const SizedBox(height: 8),
              Text('Uploaded By: ${file.uploadedBy}'),
              Text('Uploaded At: ${_formatDateTime(file.uploadedAt)}'),
              Text('Created At: ${_formatDateTime(file.createdAt)}'),
              Text('Updated At: ${_formatDateTime(file.updatedAt)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteFile(MediaFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.filename}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _mediaFiles.removeWhere((f) => f.id == file.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('File "${file.filename}" deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class MediaUploadsTab extends StatelessWidget {
  const MediaUploadsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Media Uploads'),
          Text('Coming soon...'),
        ],
      ),
    );
  }
}

class CDNVariantsTab extends StatelessWidget {
  const CDNVariantsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('CDN Variants'),
          Text('Coming soon...'),
        ],
      ),
    );
  }
}

class MediaCleanupTab extends StatelessWidget {
  const MediaCleanupTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cleaning_services, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Media Cleanup'),
          Text('Coming soon...'),
        ],
      ),
    );
  }
}
