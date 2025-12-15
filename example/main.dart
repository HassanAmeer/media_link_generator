import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_link_generator/media_link_generator.dart';

void main() {
  // Initialize MediaLink with optional config
  MediaLink(
    const MediaLinkConfig(
      enableLogging: true, // Enable debug logs
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Link Generator Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const MediaLinkDemo(),
    );
  }
}

class MediaLinkDemo extends StatefulWidget {
  const MediaLinkDemo({super.key});

  @override
  State<MediaLinkDemo> createState() => _MediaLinkDemoState();
}

class _MediaLinkDemoState extends State<MediaLinkDemo> {
  final _mediaLink = MediaLink();
  String _status = 'Ready';
  double _progress = 0;
  String? _lastUploadedLink;

  @override
  void initState() {
    super.initState();
    _initToken();
  }

  Future<void> _initToken() async {
    // Option 1: Generate token with email (one-time setup)
    // final success = await _mediaLink.generateAndSetToken('your@email.com');

    // Option 2: Set token directly (get from dashboard)
    _mediaLink.setToken('YOUR_TOKEN_HERE');

    setState(() => _status = 'Token set! Ready to upload.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Link Generator Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: $_status'),
                    if (_progress > 0) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: _progress),
                      Text('${(_progress * 100).toStringAsFixed(1)}%'),
                    ],
                    if (_lastUploadedLink != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Link: $_lastUploadedLink',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 1. Generate Token
            _buildSection(
              '1. Generate Token',
              'First-time setup - generate or set your API token',
              ElevatedButton.icon(
                icon: const Icon(Icons.key),
                label: const Text('Generate Token'),
                onPressed: _generateToken,
              ),
            ),

            // 2. Simple File Upload
            _buildSection(
              '2. Upload File (Simple)',
              'Best for files under 5MB',
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload File'),
                onPressed: _uploadSimpleFile,
              ),
            ),

            // 3. Upload from Bytes
            _buildSection(
              '3. Upload from Bytes',
              'Upload in-memory data or web files',
              ElevatedButton.icon(
                icon: const Icon(Icons.memory),
                label: const Text('Upload Bytes'),
                onPressed: _uploadFromBytes,
              ),
            ),

            // 4. Large File Upload (Chunked)
            _buildSection(
              '4. Upload Large File (Chunked)',
              'Recommended for files over 5MB',
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload Large File'),
                onPressed: _uploadLargeFile,
              ),
            ),

            // 5. Smart Upload
            _buildSection(
              '5. Smart Upload',
              'Automatically chooses best method based on file size',
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Smart Upload'),
                onPressed: _smartUpload,
              ),
            ),

            // 6. Delete File
            _buildSection(
              '6. Delete File',
              'Delete previously uploaded file',
              ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete Last Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _lastUploadedLink != null ? _deleteFile : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, Widget button) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),
            button,
          ],
        ),
      ),
    );
  }

  // ============ Action Methods ============

  Future<void> _generateToken() async {
    setState(() => _status = 'Generating token...');

    final success = await _mediaLink.generateAndSetToken('your@email.com');

    setState(() {
      _status = success
          ? 'Token generated! Token: ${_mediaLink.token}'
          : 'Failed to generate token';
    });
  }

  Future<void> _uploadSimpleFile() async {
    setState(() {
      _status = 'Uploading...';
      _progress = 0;
    });

    // In a real app, use file_picker or image_picker to get a file
    final file = File('/path/to/your/file.jpg');

    final result = await _mediaLink.uploadFile(
      file,
      folderName: 'demo_uploads',
      deviceName: 'Flutter Demo App',
      isSecret: false, // Set true for encrypted/private files
      onProgress: (progress, sent, total) {
        setState(() => _progress = progress);
      },
    );

    setState(() {
      _status = result.success
          ? 'Upload successful!'
          : 'Upload failed: ${result.message}';
      _lastUploadedLink = result.success ? result.link : null;
      _progress = 0;
    });
  }

  Future<void> _uploadFromBytes() async {
    setState(() {
      _status = 'Uploading from bytes...';
      _progress = 0;
    });

    // In a real app, this could be from camera, download, etc.
    final file = File('/path/to/your/file.pdf');
    final bytes = await file.readAsBytes();

    final result = await _mediaLink.uploadBytes(
      bytes,
      fileName: 'document.pdf',
      folderName: 'documents',
      onProgress: (progress, sent, total) {
        setState(() => _progress = progress);
      },
    );

    setState(() {
      _status = result.success
          ? 'Bytes upload successful!'
          : 'Upload failed: ${result.message}';
      _lastUploadedLink = result.success ? result.link : null;
      _progress = 0;
    });
  }

  Future<void> _uploadLargeFile() async {
    setState(() {
      _status = 'Uploading large file in chunks...';
      _progress = 0;
    });

    final file = File('/path/to/large/video.mp4');

    final result = await _mediaLink.uploadLargeFile(
      file,
      folderName: 'videos',
      isSecret: true, // Encrypted upload
      onProgress: (progress, sent, total) {
        setState(() {
          _progress = progress;
          _status = 'Uploading: ${(progress * 100).toStringAsFixed(1)}%';
        });
      },
    );

    setState(() {
      _status = result.success
          ? 'Large file uploaded!'
          : 'Upload failed: ${result.message}';
      _lastUploadedLink = result.success ? result.link : null;
      _progress = 0;
    });
  }

  Future<void> _smartUpload() async {
    setState(() {
      _status = 'Smart uploading...';
      _progress = 0;
    });

    final file = File('/path/to/any/file.zip');

    // Automatically chooses method based on file size
    final result = await _mediaLink.upload(
      file,
      folderName: 'smart_uploads',
      onProgress: (progress, sent, total) {
        setState(() => _progress = progress);
      },
    );

    setState(() {
      _status = result.success
          ? 'Smart upload successful!'
          : 'Upload failed: ${result.message}';
      _lastUploadedLink = result.success ? result.link : null;
      _progress = 0;
    });
  }

  Future<void> _deleteFile() async {
    if (_lastUploadedLink == null) return;

    setState(() => _status = 'Deleting...');

    final deleted = await _mediaLink.deleteFile(_lastUploadedLink!);

    setState(() {
      _status = deleted ? 'File deleted!' : 'Delete failed';
      if (deleted) _lastUploadedLink = null;
    });
  }
}
