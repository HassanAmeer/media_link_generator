import 'package:flutter_test/flutter_test.dart';
import 'package:media_link_generator/media_link_generator.dart';

void main() {
  group('MediaLink', () {
    test('should create singleton instance', () {
      final instance1 = MediaLink();
      final instance2 = MediaLink();
      expect(instance1, same(instance2));
    });

    test('should set and get token', () {
      const testToken = 'test_token_12345';
      MediaLink().setToken(testToken);
      expect(MediaLink().token, testToken);
    });

    test('should allow custom config', () {
      MediaLink.reset();
      const config = MediaLinkConfig(
        enableLogging: true,
        chunkSize: 512 * 1024,
      );
      final instance = MediaLink(config);
      expect(instance.config.enableLogging, true);
      expect(instance.config.chunkSize, 512 * 1024);
    });
  });

  group('UploadResponse', () {
    test('should parse JSON correctly', () {
      final json = {
        'success': true,
        'message': 'File uploaded!',
        'link': 'https://example.com/file.jpg',
        'is_encrypted': false,
        'insert_id': 123,
        'file_size_kb': 1024,
        'file_type': 'image/jpeg',
      };

      final response = UploadResponse.fromJson(json);

      expect(response.success, true);
      expect(response.message, 'File uploaded!');
      expect(response.link, 'https://example.com/file.jpg');
      expect(response.isEncrypted, false);
      expect(response.insertId, 123);
      expect(response.fileSizeKb, 1024);
      expect(response.fileType, 'image/jpeg');
      expect(response.hasLink, true);
    });

    test('should handle missing fields', () {
      final json = {
        'success': false,
        'message': 'Error',
      };

      final response = UploadResponse.fromJson(json);

      expect(response.success, false);
      expect(response.link, '');
      expect(response.hasLink, false);
    });
  });

  group('TokenResponse', () {
    test('should parse JSON correctly', () {
      final json = {
        'success': true,
        'message': 'Token generated',
        'token': 'abc123',
      };

      final response = TokenResponse.fromJson(json);

      expect(response.success, true);
      expect(response.message, 'Token generated');
      expect(response.token, 'abc123');
    });
  });
}
