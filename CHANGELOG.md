# Changelog

## [1.0.0] - 2024-12-11

### Added
- Major update with complete rewrite for better API compatibility
- `MediaLink` singleton client for easy API access
- `uploadFile()` - Multipart file upload for small files
- `uploadBytes()` - Upload from bytes/memory (web compatible)
- `uploadLargeFile()` - Chunked upload for large files (5MB+)
- `uploadLargeFileBase64()` - Chunked Base64 upload for web
- `upload()` - Smart upload that auto-selects best method
- `deleteFile()` - Delete files by link
- `generateToken()` - Generate API token by email
- `setToken()` - Set API token manually
- `MediaLinkConfig` - Customizable configuration
- Progress tracking with `ProgressCallback`
- Proper error handling and response models
- Full null safety support
- Comprehensive documentation and examples
- `dbFolderId` parameter for database folder organization

### Changed
- Updated API endpoints to match current backend
- Improved error handling with detailed messages
- Added MIME type detection for uploads
- Singleton pattern for easy global access

### Deprecated
- `uploadSimpleFile()` - Use `uploadFile()` instead
- `uploadFileInBytes()` - Use `uploadBytes()` instead
- `generateTokenByEmail()` - Use `generateToken()` instead

### Fixed
- Correct API endpoint URLs
- Proper multipart form field names
- JSON body structure for Base64 uploads

## [0.0.4] - Previous versions
- Initial releases with basic functionality
