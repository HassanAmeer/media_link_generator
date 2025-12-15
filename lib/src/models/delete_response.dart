/// Response model for file deletion API
class DeleteResponse {
  /// Whether the deletion was successful
  final bool success;

  /// Message from the API
  final String message;

  /// Additional data from the response
  final dynamic data;

  DeleteResponse({required this.success, required this.message, this.data});

  factory DeleteResponse.fromJson(Map<String, dynamic> json) {
    return DeleteResponse(
      success: json['success'] == true || json['success'] == 'true',
      message: json['message']?.toString() ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data,
  };

  @override
  String toString() => 'DeleteResponse(success: $success, message: $message)';
}
