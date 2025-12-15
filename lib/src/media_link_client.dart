import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import 'models/upload_response.dart';
import 'models/token_response.dart';
import 'models/delete_response.dart';
import 'media_link_config.dart';

/// Progress callback type for upload/download operations
typedef ProgressCallback = void Function(double progress, int sent, int total);

/// MediaLink - Upload any file and get instant shareable links
///
/// A Firebase Storage alternative with:
/// - Multipart file upload
/// - Base64 file upload
/// - Chunked upload for large files
/// - Encryption support
/// - Progress tracking
class MediaLink {
  static MediaLink? _instance;

  final Dio _dio;
  final MediaLinkConfig config;
  String? _token;

  /// Private constructor
  MediaLink._internal(this.config)
      : _dio = Dio(
          BaseOptions(
            baseUrl: config.baseUrl,
            connectTimeout: Duration(milliseconds: config.connectTimeout),
            receiveTimeout: Duration(milliseconds: config.receiveTimeout),
            sendTimeout: Duration(milliseconds: config.sendTimeout),
            headers: {'Accept': 'application/json'},
          ),
        );

  /// Get auth headers with Bearer token
  Map<String, String> _getAuthHeaders() {
    if (_token != null && _token!.isNotEmpty) {
      return {'Authorization': 'Bearer $_token'};
    }
    return {};
  }

  /// Get singleton instance with optional custom config
  factory MediaLink([MediaLinkConfig? config]) {
    _instance ??= MediaLink._internal(config ?? MediaLinkConfig.defaultConfig);
    return _instance!;
  }

  /// Reset instance (useful for testing or changing config)
  static void reset() {
    _instance = null;
  }

  /// Create a new instance with custom config (non-singleton)
  static MediaLink create(MediaLinkConfig config) {
    return MediaLink._internal(config);
  }

  // ============ Token Management ============

  /// Get current API token
  String? get token => _token;

  /// Set API token manually
  ///
  /// Get your token from: https://link.thelocalrent.com/users/auth.html
  void setToken(String token) {
    _token = token;
    _log('✅ Token set successfully');
  }

  /// Generate or retrieve token by email
  ///
  /// If this is the first time, a new token will be created.
  /// Default password for new accounts is: 12345678
  Future<String?> generateToken(String email) async {
    try {
      final response = await _dio.post(
        '/api/gen_token',
        data: jsonEncode({'email': email}),
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode == 200) {
        final data = TokenResponse.fromJson(response.data);
        if (data.success && data.token != null) {
          _token = data.token;
          _log('✅ Token generated: ${_token!.substring(0, 8)}...');
          return _token;
        }
        _log('❌ Token generation failed: ${data.message}');
      }
    } catch (e) {
      _log('❌ Error generating token: $e');
    }
    return null;
  }

  /// Generate token and set it automatically
  /// @deprecated Use generateToken() instead
  Future<String?> generateTokenByEmail(
    String email, {
    bool shouldPrint = false,
  }) async {
    if (shouldPrint) {
      return MediaLink(
        const MediaLinkConfig(enableLogging: true),
      ).generateToken(email);
    }
    return generateToken(email);
  }

  /// Generate token and set it automatically
  Future<bool> generateAndSetToken(String email) async {
    final token = await generateToken(email);
    return token != null;
  }

  // ============ File Upload Methods ============

  /// Upload a file using multipart form data (recommended for most files)
  ///
  /// Example:
  /// ```dart
  /// final result = await MediaLink().uploadFile(
  ///   File('/path/to/image.jpg'),
  ///   folderName: 'photos',
  ///   onProgress: (progress, sent, total) {
  ///     print('Upload: ${(progress * 100).toStringAsFixed(1)}%');
  ///   },
  /// );
  /// if (result.success) print('Link: ${result.link}');
  /// ```
  Future<UploadResponse> uploadFile(
    File file, {
    String folderName = 'uploads',
    String deviceName = 'flutter_app',
    bool isSecret = false,
    int? dbFolderId,
    ProgressCallback? onProgress,
  }) async {
    if (!_checkToken()) {
      return UploadResponse(
        success: false,
        message: 'Token not set. Call setToken() or generateToken() first.',
      );
    }

    if (!await file.exists()) {
      return UploadResponse(
        success: false,
        message: 'File does not exist: ${file.path}',
      );
    }

    try {
      final fileName = path.basename(file.path);
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      final formData = FormData.fromMap({
        'folder_name': _sanitizeFolderName(folderName),
        'is_secret': isSecret ? '1' : '0',
        'from_device_name': deviceName,
        if (dbFolderId != null) 'db_folder_id': dbFolderId,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final response = await _dio.post(
        '/api/upload_file',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: _getAuthHeaders(),
        ),
        onSendProgress: (sent, total) {
          onProgress?.call(sent / total, sent, total);
        },
      );

      if (response.statusCode == 200) {
        final data = UploadResponse.fromJson(response.data);
        if (data.success) {
          _log('✅ File uploaded: ${data.link}');
        }
        return data;
      }

      return UploadResponse(
        success: false,
        message: 'Upload failed with status: ${response.statusCode}',
      );
    } catch (e) {
      _log('❌ Upload error: $e');
      return UploadResponse(success: false, message: 'Upload error: $e');
    }
  }

  /// @deprecated Use uploadFile() instead
  Future<UploadResponse> uploadSimpleFile(
    File file, {
    String? folderName,
    String? fromDeviceName,
    bool isSecret = false,
    Function(double)? onUploadProgress,
    bool shouldPrint = false,
  }) async {
    return uploadFile(
      file,
      folderName: folderName ?? 'uploads',
      deviceName: fromDeviceName ?? 'flutter_app',
      isSecret: isSecret,
      onProgress: onUploadProgress != null
          ? (progress, sent, total) => onUploadProgress(progress)
          : null,
    );
  }

  /// Upload file from bytes (useful for web or in-memory files)
  ///
  /// Example:
  /// ```dart
  /// final bytes = await file.readAsBytes();
  /// final result = await MediaLink().uploadBytes(
  ///   bytes,
  ///   fileName: 'document.pdf',
  ///   folderName: 'documents',
  /// );
  /// ```
  Future<UploadResponse> uploadBytes(
    Uint8List bytes, {
    required String fileName,
    String folderName = 'uploads',
    String deviceName = 'flutter_app',
    bool isSecret = false,
    int? dbFolderId,
    ProgressCallback? onProgress,
  }) async {
    if (!_checkToken()) {
      return UploadResponse(
        success: false,
        message: 'Token not set. Call setToken() or generateToken() first.',
      );
    }

    try {
      final base64String = base64Encode(bytes);
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

      // Add data URL prefix for proper MIME type detection
      final base64WithPrefix = 'data:$mimeType;base64,$base64String';

      final body = {
        'folder_name': _sanitizeFolderName(folderName),
        'is_secret': isSecret,
        'file_base64': base64WithPrefix,
        if (dbFolderId != null) 'db_folder_id': dbFolderId,
      };

      final response = await _dio.post(
        '/api/upload_base64',
        data: jsonEncode(body),
        options: Options(
          contentType: 'application/json',
          headers: _getAuthHeaders(),
        ),
        onSendProgress: (sent, total) {
          onProgress?.call(sent / total, sent, total);
        },
      );

      if (response.statusCode == 200) {
        final data = UploadResponse.fromJson(response.data);
        if (data.success) {
          _log('✅ Bytes uploaded: ${data.link}');
        }
        return data;
      }

      return UploadResponse(
        success: false,
        message: 'Upload failed with status: ${response.statusCode}',
      );
    } catch (e) {
      _log('❌ Upload error: $e');
      return UploadResponse(success: false, message: 'Upload error: $e');
    }
  }

  /// @deprecated Use uploadBytes() instead
  Future<UploadResponse> uploadFileInBytes(
    List<int> fileBytes, {
    String? folderName,
    String? fromDeviceName,
    bool isSecret = false,
    Function(double)? onUploadProgress,
    bool shouldPrint = false,
  }) async {
    return uploadBytes(
      Uint8List.fromList(fileBytes),
      fileName: 'file_${DateTime.now().millisecondsSinceEpoch}',
      folderName: folderName ?? 'uploads',
      deviceName: fromDeviceName ?? 'flutter_app',
      isSecret: isSecret,
      onProgress: onUploadProgress != null
          ? (progress, sent, total) => onUploadProgress(progress)
          : null,
    );
  }

  /// Upload large file in chunks (recommended for files > 5MB)
  ///
  /// Automatically splits the file into chunks and uploads sequentially.
  /// Provides progress updates for the entire upload process.
  ///
  /// Example:
  /// ```dart
  /// final result = await MediaLink().uploadLargeFile(
  ///   File('/path/to/video.mp4'),
  ///   folderName: 'videos',
  ///   onProgress: (progress, sent, total) {
  ///     print('Upload: ${(progress * 100).toStringAsFixed(1)}%');
  ///   },
  /// );
  /// ```
  Future<UploadResponse> uploadLargeFile(
    File file, {
    String folderName = 'uploads',
    String deviceName = 'flutter_app',
    bool isSecret = false,
    int? chunkSize,
    int? dbFolderId,
    ProgressCallback? onProgress,
  }) async {
    if (!_checkToken()) {
      return UploadResponse(
        success: false,
        message: 'Token not set. Call setToken() or generateToken() first.',
      );
    }

    if (!await file.exists()) {
      return UploadResponse(
        success: false,
        message: 'File does not exist: ${file.path}',
      );
    }

    try {
      final bytes = await file.readAsBytes();
      final effectiveChunkSize = chunkSize ?? config.chunkSize;
      final totalChunks = (bytes.length / effectiveChunkSize).ceil();
      final fileId = _generateFileId();

      _log('📦 Starting chunked upload: $totalChunks chunks');

      UploadResponse? lastResponse;

      for (int i = 0; i < totalChunks; i++) {
        final start = i * effectiveChunkSize;
        final end = (start + effectiveChunkSize > bytes.length)
            ? bytes.length
            : start + effectiveChunkSize;
        final chunk = bytes.sublist(start, end);

        final formData = FormData.fromMap({
          'folder_name': _sanitizeFolderName(folderName),
          'is_secret': isSecret ? '1' : '0',
          'file_id': fileId,
          'chunk_index': i,
          'total_chunks': totalChunks,
          if (dbFolderId != null) 'db_folder_id': dbFolderId,
          'chunk_file': MultipartFile.fromBytes(chunk, filename: 'chunk_$i'),
        });

        final response = await _dio.post(
          '/api/upload_file_chunks',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            headers: _getAuthHeaders(),
          ),
        );

        if (response.statusCode == 200) {
          lastResponse = UploadResponse.fromJson(response.data);

          // Calculate overall progress
          final overallProgress = (i + 1) / totalChunks;
          final totalSent = end;
          onProgress?.call(overallProgress, totalSent, bytes.length);

          _log('📤 Chunk ${i + 1}/$totalChunks uploaded');
        } else {
          return UploadResponse(
            success: false,
            message: 'Chunk $i failed with status: ${response.statusCode}',
          );
        }
      }

      if (lastResponse?.success == true) {
        _log('✅ Large file uploaded: ${lastResponse!.link}');
      }

      return lastResponse ??
          UploadResponse(success: false, message: 'Upload failed');
    } catch (e) {
      _log('❌ Chunked upload error: $e');
      return UploadResponse(
        success: false,
        message: 'Chunked upload error: $e',
      );
    }
  }

  /// Upload large file using Base64 chunks (for web compatibility)
  Future<UploadResponse> uploadLargeFileBase64(
    Uint8List bytes, {
    String folderName = 'uploads',
    String deviceName = 'flutter_app',
    bool isSecret = false,
    int? chunkSize,
    int? dbFolderId,
    ProgressCallback? onProgress,
  }) async {
    if (!_checkToken()) {
      return UploadResponse(
        success: false,
        message: 'Token not set. Call setToken() or generateToken() first.',
      );
    }

    try {
      final base64String = base64Encode(bytes);
      final effectiveChunkSize =
          chunkSize ?? (config.chunkSize * 4 ~/ 3); // Base64 overhead
      final totalChunks = (base64String.length / effectiveChunkSize).ceil();
      final fileId = _generateFileId();

      _log('📦 Starting Base64 chunked upload: $totalChunks chunks');

      UploadResponse? lastResponse;

      for (int i = 0; i < totalChunks; i++) {
        final start = i * effectiveChunkSize;
        final end = (start + effectiveChunkSize > base64String.length)
            ? base64String.length
            : start + effectiveChunkSize;
        final chunkData = base64String.substring(start, end);

        final body = {
          'folder_name': _sanitizeFolderName(folderName),
          'is_secret': isSecret,
          'file_id': fileId,
          'chunk_index': i,
          'total_chunks': totalChunks,
          'chunk_data': chunkData,
          if (dbFolderId != null) 'db_folder_id': dbFolderId,
        };

        final response = await _dio.post(
          '/api/upload_base64_chunks',
          data: jsonEncode(body),
          options: Options(
            contentType: 'application/json',
            headers: _getAuthHeaders(),
          ),
        );

        if (response.statusCode == 200) {
          lastResponse = UploadResponse.fromJson(response.data);

          final overallProgress = (i + 1) / totalChunks;
          final totalSent = end;
          onProgress?.call(overallProgress, totalSent, base64String.length);

          _log('📤 Base64 chunk ${i + 1}/$totalChunks uploaded');
        } else {
          return UploadResponse(
            success: false,
            message: 'Chunk $i failed with status: ${response.statusCode}',
          );
        }
      }

      if (lastResponse?.success == true) {
        _log('✅ Large file (Base64) uploaded: ${lastResponse!.link}');
      }

      return lastResponse ??
          UploadResponse(success: false, message: 'Upload failed');
    } catch (e) {
      _log('❌ Base64 chunked upload error: $e');
      return UploadResponse(
        success: false,
        message: 'Base64 chunked upload error: $e',
      );
    }
  }

  /// Smart upload - automatically chooses the best method based on file size
  ///
  /// - Files < 5MB: Regular multipart upload
  /// - Files >= 5MB: Chunked upload
  ///
  /// Example:
  /// ```dart
  /// final result = await MediaLink().upload(
  ///   File('/path/to/file.zip'),
  ///   folderName: 'backups',
  ///   onProgress: (p, s, t) => print('${(p*100).toInt()}%'),
  /// );
  /// ```
  Future<UploadResponse> upload(
    File file, {
    String folderName = 'uploads',
    String deviceName = 'flutter_app',
    bool isSecret = false,
    int? dbFolderId,
    ProgressCallback? onProgress,
  }) async {
    final stat = await file.stat();
    const fiveMB = 5 * 1024 * 1024;

    if (stat.size >= fiveMB) {
      _log(
        '📁 File size: ${(stat.size / 1024 / 1024).toStringAsFixed(2)} MB - using chunked upload',
      );
      return uploadLargeFile(
        file,
        folderName: folderName,
        deviceName: deviceName,
        isSecret: isSecret,
        dbFolderId: dbFolderId,
        onProgress: onProgress,
      );
    } else {
      _log(
        '📁 File size: ${(stat.size / 1024).toStringAsFixed(2)} KB - using direct upload',
      );
      return uploadFile(
        file,
        folderName: folderName,
        deviceName: deviceName,
        isSecret: isSecret,
        dbFolderId: dbFolderId,
        onProgress: onProgress,
      );
    }
  }

  // ============ File Management ============

  /// Delete a file by its link
  ///
  /// Example:
  /// ```dart
  /// final deleted = await MediaLink().deleteFile(
  ///   'https://link.thelocalrent.com/link/v?t=12345&tk=abc123'
  /// );
  /// if (deleted) print('File deleted!');
  /// ```
  Future<bool> deleteFile(String fileLink, {bool shouldPrint = false}) async {
    if (!_checkToken()) {
      _log('❌ Token required for delete operation');
      return false;
    }

    try {
      final response = await _dio.post(
        '/api/deletefile',
        data: jsonEncode({'filelink': fileLink}),
        options: Options(
          contentType: 'application/json',
          headers: _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        final data = DeleteResponse.fromJson(response.data);
        if (data.success) {
          _log('🗑️ File deleted successfully');
          return true;
        }
        _log('❌ Delete failed: ${data.message}');
      }
    } catch (e) {
      _log('❌ Delete error: $e');
    }
    return false;
  }

  // ============ Helper Methods ============

  bool _checkToken() {
    if (_token == null || _token!.isEmpty) {
      _log('❌ Token not set. Call setToken() or generateToken() first.');
      return false;
    }
    return true;
  }

  String _sanitizeFolderName(String name) {
    // Only allow alphanumeric, underscore, and dash
    return name.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  String _generateFileId() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}_${now.microsecond}';
  }

  void _log(String message) {
    if (config.enableLogging) {
      debugPrint('[MediaLink] $message');
    }
  }
}
