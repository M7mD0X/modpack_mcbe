/// Verification status for a mod from the API
class VerificationStatus {
  final bool verified;
  final String? verifiedBy;
  final DateTime? verifiedAt;

  const VerificationStatus({
    this.verified = false,
    this.verifiedBy,
    this.verifiedAt,
  });

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      verified: json['verified'] as bool? ?? false,
      verifiedBy: json['verifiedBy']?.toString(),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'].toString())
          : null,
    );
  }
}

/// Authentication result
class AuthResult {
  final bool success;
  final String? token;
  final AuthResultData? user;
  final String? error;

  const AuthResult({
    this.success = false,
    this.token,
    this.user,
    this.error,
  });

  const AuthResult.successful(this.token, this.user)
      : success = true,
        error = null;

  const AuthResult.failed(this.error)
      : success = false,
        token = null,
        user = null;
}

/// User data returned from auth API
class AuthResultData {
  final String id;
  final String username;
  final String email;
  final bool emailVerified;

  const AuthResultData({
    required this.id,
    required this.username,
    required this.email,
    this.emailVerified = false,
  });

  factory AuthResultData.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    return AuthResultData(
      id: user['id']?.toString() ?? '',
      username: user['username']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      emailVerified: user['emailVerified'] as bool? ?? false,
    );
  }
}

/// API error response
class ApiError {
  final int statusCode;
  final String message;
  final dynamic data;

  const ApiError({
    this.statusCode = 0,
    this.message = '',
    this.data,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message']?.toString() ?? 'Unknown error',
      data: json['data'],
    );
  }

  @override
  String toString() => message.isNotEmpty ? message : 'Error $statusCode';
}

/// Sort options for mod search
enum SortOption {
  featured('featured', 'Featured'),
  popular('popularity', 'Popular'),
  downloads('totalDownloads', 'Downloads'),
  updated('dateModified', 'Updated'),
  newest('dateCreated', 'Newest'),
  name('name', 'Name'),
  rating('rating', 'Rating');

  const SortOption(this.value, this.label);
  final String value;
  final String label;
}

/// CurseForge MCBE class IDs
class CfClassIds {
  static const int mcbe = 4471;
}

/// Category ID mapping for common MCBE categories
class CfCategoryIds {
  static const Map<String, int> categoryMap = {
    'all': -1,
    'mobs': 423,
    'weapons': 421,
    'tools': 417,
    'biomes': 422,
    'blocks': 416,
    'armor': 419,
    'vehicles': 418,
    'magic': 428,
    'furniture': 429,
    'survival': 427,
    'adventure': 424,
    'decoration': 426,
    'science': 430,
    'storage': 425,
  };

  static int? idFor(String name) => categoryMap[name.toLowerCase()];
  static String? nameFor(int id) {
    for (final entry in categoryMap.entries) {
      if (entry.value == id) return entry.key;
    }
    return null;
  }
}

/// Constants for API
class ApiConstants {
  static const String cfApiKeyHeader = 'x-api-key';
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  static const String mcbeGameId = '4471';
  static const String mcbeSlug = 'minecraft-bedrock';
}
