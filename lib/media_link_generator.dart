import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

// Models for API responses

class TokenResponse {
  final String status;
  final String message;
  final String? token;

  TokenResponse({
    required this.status,
    required this.message,
    this.token,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      token: json['token'] as String?,
    );
  }
}

class UploadFile {
  final bool success;
  final String message;
  final String link;
  final bool isEncrypted;
  final int insertId;
  final int fileSizeKb;
  final String? fileType;

  UploadFile({
    required this.success,
    required this.message,
    this.link = "",
    this.isEncrypted = false,
    this.insertId = 0,
    this.fileSizeKb = 0,
    this.fileType,
  });

  factory UploadFile.fromJson(Map<String, dynamic> json) {
    return UploadFile(
      success: json['success'] as bool,
      message: json['message'] as String,
      link: json['link'] as String,
      isEncrypted: json['is_encrypted'] as bool,
      insertId: json['insert_id'] as int,
      fileSizeKb: json['file_size_kb'] as int,
      fileType: json['file_type'] as String,
    );
  }
Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'link': link,
      'is_encrypted': isEncrypted,
      'insert_id': insertId,
      'file_size_kb': fileSizeKb,
      'file_type': fileType,
    };
  }
}

class DeleteResponse {
  final String status;
  final String message;
  final dynamic data;

  DeleteResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory DeleteResponse.fromJson(Map<String, dynamic> json) {
    return DeleteResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: json['data'],
    );
  }
}

// API Service Class
class MediaLink {
  final Dio _dio;
  String? _token;

  MediaLink()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://thelocalrent.com/link/api/',
            headers: {'Content-Type': 'application/json'},
          ),
        );

  // Generate and set token
  Future<String?> generateAndSetToken(String email, {bool shouldPrint = false}) async {
    try {
      final response = await _dio.post('gen_token.php', data: jsonEncode({'email': email}));
      if (response.statusCode == 200) {
        final data = TokenResponse.fromJson(response.data);
        if (data.status == 'success' && data.token != null) {
          _token = data.token;
          if (shouldPrint) debugPrint('Token generation success: true');
          return _token;
        }
      }
    } catch (e) {
      if (shouldPrint) debugPrint('Error generating token: $e');
    }
    if (shouldPrint) debugPrint('Token generation success: false');
    return null;
  }

  // Set token manually
  void setToken(String token) {
    _token = token;
  }

  // Get current token
  String? get token => _token;

  // Upload file with progress callback
  Future<UploadFile?> uploadFile(
    File file, {
    String? folderName,
    String? fromDeviceName,
    bool isSecret = false,
    Function(double)? onUploadProgress,
    bool shouldPrint = false,
  }) async {
    try {
      if(token!.isEmpty){
        debugPrint('Please Generate Token');
        return UploadFile(
          success: false,
          message: "Please Generate Token");
      }
      FormData formData = FormData.fromMap({
        'token': token,
        'folderName': folderName ?? '',
        'fromDeviceName': fromDeviceName ?? '',
        'isSecret': isSecret ? '1' : '0',
        'file': await MultipartFile.fromFile(file.path),
      });

      final response = await _dio.post(
        'uploadfiles.php',
        data: formData,
        onSendProgress: (int sent, int total) {
          if (onUploadProgress != null) {
            onUploadProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        final data = UploadFile.fromJson(response.data);
        if (data.success) {
          if (shouldPrint) debugPrint('Upload success: true');
          return data;
        }
      }
    } catch (e) {
      if (shouldPrint) debugPrint('Error uploading file: $e');
    }
    if (shouldPrint) debugPrint('Upload success: false');
    return null;
  }

  // Delete file by link
  Future<bool> deleteFile(String filelink, {bool shouldPrint = false}) async {
    try {
      final response = await _dio.delete(
        'deletefile.php',
        data: jsonEncode({'filelink': filelink}),
      );
      if (response.statusCode == 200) {
        final data = DeleteResponse.fromJson(response.data);
        if (data.status == 'success') {
          if (shouldPrint) debugPrint('🗑️ Delete success: true');
          return true;
        }
      }
    } catch (e) {
      if (shouldPrint) debugPrint('Error deleting file: $e');
    }
    if (shouldPrint) debugPrint('Delete success: false');
    return false;
  }
}