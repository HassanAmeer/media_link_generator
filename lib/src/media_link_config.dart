/// Configuration for MediaLink client
class MediaLinkConfig {
  /// Base URL for the MediaLink API
  final String baseUrl;

  /// Default chunk size for chunked uploads (in bytes)
  /// Default: 1MB (1024 * 1024)
  final int chunkSize;

  /// Connection timeout in milliseconds
  final int connectTimeout;

  /// Receive timeout in milliseconds
  final int receiveTimeout;

  /// Send timeout in milliseconds
  final int sendTimeout;

  /// Enable debug logging
  final bool enableLogging;

  const MediaLinkConfig({
    this.baseUrl = 'https://link.thelocalrent.com/api',
    this.chunkSize = 1024 * 1024, // 1MB default
    this.connectTimeout = 30000,
    this.receiveTimeout = 60000,
    this.sendTimeout = 60000,
    this.enableLogging = false,
  });

  /// Default configuration
  static const MediaLinkConfig defaultConfig = MediaLinkConfig();

  /// Copy with modified values
  MediaLinkConfig copyWith({
    String? baseUrl,
    int? chunkSize,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
    bool? enableLogging,
  }) {
    return MediaLinkConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      chunkSize: chunkSize ?? this.chunkSize,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      enableLogging: enableLogging ?? this.enableLogging,
    );
  }
}
