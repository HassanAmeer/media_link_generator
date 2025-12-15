/// Response model for token generation API
class TokenResponse {
  /// Whether the token generation was successful
  final bool success;

  /// Message from the API
  final String message;

  /// The generated or retrieved API token
  final String? token;

  TokenResponse({required this.success, required this.message, this.token});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      success: json['success'] == true || json['success'] == 'true',
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'token': token,
  };

  @override
  String toString() =>
      'TokenResponse(success: $success, message: $message, token: $token)';
}
