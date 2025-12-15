# Media Link Generator 🚀
**Free Cloud Storage for Flutter** - Upload any file and get instant shareable links.

A Firebase Storage alternative with encryption support, chunked uploads for large files, and progress tracking.

## please move to new package stable version -> livedb
- 📚 Documentation & Access
[**📖 API Documentation**](https://livedbs.web.app/api-docs) • [**🔑 Get API Key (Login)**](https://livedbs.web.app/)

[![pub package](https://img.shields.io/pub/v/media_link_generator.svg)](https://pub.dev/packages/media_link_generator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)




## Features ✨

- 📁 **Upload Any File Type** - Images, videos, documents, ZIP files, and more
- 🔒 **Encryption Support** - Optional secure/encrypted file storage
- 📊 **Progress Tracking** - Real-time upload progress callbacks
- 📦 **Chunked Uploads** - Automatic chunking for large files (100MB+)
- 🎯 **Smart Upload** - Automatically chooses the best upload method
- 🗑️ **File Management** - Delete files when no longer needed
- 🌐 **Cross-Platform** - Works on iOS, Android, Web, Desktop
- 💯 **Free to Use** - No hidden costs

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  media_link_generator: ^1.0.0
```

Then run:
```bash
flutter pub get
```

## Quick Start 🚀

### 1. Initialize & Set Token

```dart
import 'package:media_link_generator/media_link_generator.dart';

void main() {
  // Option 1: Set token directly (recommended)
  MediaLink().setToken('YOUR_TOKEN_HERE');
  
  // Option 2: Generate token with email
  // await MediaLink().generateAndSetToken('your@email.com');
  
  runApp(MyApp());
}
```

> 📝 **Get your token**: Visit [Media Link Dashboard](https://livedbs.web.app)
> Default password for new accounts: `12345678`

### 2. Upload a File

```dart
import 'dart:io';
import 'package:media_link_generator/media_link_generator.dart';

// Simple upload with progress
final result = await MediaLink().uploadFile(
  File('/path/to/image.jpg'),
  folderName: 'photos',
  onProgress: (progress, sent, total) {
    print('Upload: ${(progress * 100).toInt()}%');
  },
);

if (result.success) {
  print('✅ File uploaded!');
  print('📎 Link: ${result.link}');
} else {
  print('❌ Error: ${result.message}');
}
```

### 3. Upload Large Files (Chunked)

```dart
// For files > 5MB, use chunked upload
final result = await MediaLink().uploadLargeFile(
  File('/path/to/video.mp4'),
  folderName: 'videos',
  isSecret: true, // Encrypted storage
  onProgress: (progress, sent, total) {
    print('Uploading: ${(progress * 100).toInt()}%');
  },
);
```

### 4. Smart Upload (Recommended)

```dart
// Automatically chooses best method based on file size
final result = await MediaLink().upload(
  File('/path/to/any_file.zip'),
  folderName: 'backups',
  onProgress: (progress, sent, total) {
    print('${(progress * 100).toInt()}%');
  },
);
```

### 5. Upload from Bytes (Web/Memory)

```dart
// Useful for web or in-memory files
final bytes = await file.readAsBytes();
final result = await MediaLink().uploadBytes(
  bytes,
  fileName: 'document.pdf',
  folderName: 'documents',
);
```

### 6. Delete a File

```dart
final deleted = await MediaLink().deleteFile(
  'https://livedbs.web.app/v?t=12345&tk=abc'
);

if (deleted) {
  print('🗑️ File deleted!');
}
```

## Configuration ⚙️

```dart
// Custom configuration
MediaLink(MediaLinkConfig(
  baseUrl: 'https://livedbs.web.app/api',
  chunkSize: 1024 * 1024, // 1MB chunks
  enableLogging: true, // Debug logs
  connectTimeout: 30000,
  receiveTimeout: 60000,
));
```

## Authorization 🔐

**Important:** This package uses HTTP header-based authorization for all API requests.

When you call `setToken()` or `generateToken()`, the token is automatically included in the `Authorization: Bearer <token>` header for all subsequent requests. This is the industry standard approach and provides better security than sending tokens in the request payload.

```dart
// Token is automatically included in headers for all requests
MediaLink().setToken('YOUR_TOKEN_HERE');

// All uploads now use Authorization header automatically
await MediaLink().uploadFile(file);  // Bearer token sent in headers
```

## Upload Methods Comparison

| Method | Best For | Max Size |
|--------|----------|----------|
| `uploadFile()` | Small files (<5MB) | ~10MB |
| `uploadBytes()` | In-memory/web files | ~10MB |
| `uploadLargeFile()` | Large files (videos, etc.) | 100MB+ |
| `upload()` | Any file (auto-detect) | 100MB+ |

## Common Parameters

All upload methods accept these parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `folderName` | String | No | Target folder name (default: 'uploads') |
| `deviceName` | String | No | Device/source identifier (default: 'flutter_app') |
| `isSecret` | bool | No | Enable encryption (default: false) |
| `dbFolderId` | int? | No | Optional database folder ID for organization |
| `onProgress` | Function? | No | Progress callback `(double, int, int)` |

## Response Models

### UploadResponse
```dart
UploadResponse(
  success: true,
  message: 'File uploaded successfully',
  link: 'https://livedbs.web.app/v?t=123&tk=abc',
  isEncrypted: false,
  insertId: 12345,
  fileSizeKb: 1024,
  fileType: 'image/jpeg',
)
```

### Check if upload has valid link
```dart
if (result.hasLink) {
  print('Link: ${result.link}');
}
```

## Backward Compatibility

For users upgrading from older versions, the following deprecated methods are still available:

```dart
// Old method (still works)
await MediaLink().uploadSimpleFile(file, folderName: 'test');

// New method (recommended)
await MediaLink().uploadFile(file, folderName: 'test');

// Old method (still works)
await MediaLink().uploadFileInBytes(bytes);

// New method (recommended)
await MediaLink().uploadBytes(bytes, fileName: 'file.pdf');
```

## Full Example

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_link_generator/media_link_generator.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  double _progress = 0;
  String? _uploadedLink;

  @override
  void initState() {
    super.initState();
    MediaLink().setToken('YOUR_TOKEN');
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    setState(() => _progress = 0);

    final result = await MediaLink().upload(
      File(image.path),
      folderName: 'app_uploads',
      onProgress: (progress, sent, total) {
        setState(() => _progress = progress);
      },
    );

    if (result.success) {
      setState(() => _uploadedLink = result.link);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded! Link copied.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Media Link Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_progress > 0)
              CircularProgressIndicator(value: _progress),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAndUpload,
              child: Text('Pick & Upload Image'),
            ),
            if (_uploadedLink != null)
              Padding(
                padding: EdgeInsets.all(16),
                child: SelectableText(_uploadedLink!),
              ),
          ],
        ),
      ),
    );
  }
}
```

## API Documentation
📚 Full API documentation: [https://livedbs.web.app/api-docs](https://livedbs.web.app/api-docs)

## View Your Files
🗂️ Manage your uploaded files: [https://livedbs.web.app/](https://livedbs.web.app/)

[**📖 API Documentation**](https://livedbs.web.app/api-docs) • [**🔑 Get API Key (Login)**](https://livedbs.web.app/)

## License

MIT License - see [LICENSE](LICENSE) file.

## Support

- 🐛 [Report Issues](https://github.com/HassanAmeer/media_link_generator/issues)
- 💡 [Request Features](https://github.com/HassanAmeer/media_link_generator/issues)
- ⭐ Star the repo if you find it useful!
