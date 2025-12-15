/// Response model for file upload API
class UploadResponse {
  /// Whether the upload was successful
  final bool success;

  /// Message from the API
  final String message;

  /// The generated link to access the file
  final String link;

  /// Whether the file is encrypted (secret)
  final bool isEncrypted;

  /// Database insert ID for the file record
  final int insertId;

  /// File size in kilobytes
  final int fileSizeKb;

  /// MIME type of the uploaded file
  final String? fileType;

  UploadResponse({
    required this.success,
    required this.message,
    this.link = '',
    this.isEncrypted = false,
    this.insertId = 0,
    this.fileSizeKb = 0,
    this.fileType,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      success: json['success'] == true || json['success'] == 'true',
      message: json['message']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      isEncrypted: json['is_encrypted'] == true || json['is_encrypted'] == 1,
      insertId: _parseIntSafe(json['insert_id']),
      fileSizeKb: _parseIntSafe(json['file_size_kb']),
      fileType: json['file_type']?.toString(),
    );
  }

  static int _parseIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'link': link,
    'is_encrypted': isEncrypted,
    'insert_id': insertId,
    'file_size_kb': fileSizeKb,
    'file_type': fileType,
  };

  @override
  String toString() =>
      'UploadResponse(success: $success, message: $message, link: $link, isEncrypted: $isEncrypted, fileSizeKb: $fileSizeKb, fileType: $fileType)';

  /// Check if upload was successful and has a valid link
  bool get hasLink => success && link.isNotEmpty;
}
