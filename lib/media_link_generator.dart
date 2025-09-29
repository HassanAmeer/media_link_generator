import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MediaLink {
  static final Dio _dio = Dio();

  static const String _baseUrl =
      'https://thelocalrent.com/tempi/api/uploadfiles.php';

  // Upload file with all required parameters
  static Future<String> generate({
    required File file,
    required String folderName,
    required bool isSecret,
    required String fromDeviceName,

    void Function(int, int)? onSendProgress,
  }) async {
    try {
      // Create FormData
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'folderName': folderName,
        'isSecret': isSecret == true ? 1 : 0,
        'fromDeviceName': fromDeviceName,
      });

      // Make POST request
      Response response = await _dio.post(
        _baseUrl,
        data: formData,
        onSendProgress: onSendProgress,
        // 1 is count total upload , second is ttoal can be uploadiun mb or size
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
        ),
      );

      debugPrint("👉 response.data: ${response.data}");

      // ✅ Fix: return direct Map value

      return response.data['data']['link'];
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        return e.response!.data;
      } else {
        var error = {
          'status': 'error',
          'message': 'Network error: ${e.message}',
          'data': null,
        };
        debugPrint("$error");
      }
      return "";
    } catch (e) {
      // Handle other errors
      var error = {
        'status': 'error',
        'message': 'Unexpected error: $e',
        'data': null,
      };
      debugPrint("$error");
    }
    return "";
  }
}
