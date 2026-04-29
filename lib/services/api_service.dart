import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cf_mod.dart';
import '../models/api_types.dart';

/// CurseForge API service for browsing MCBE mods.
class ApiService {
  static const String _cfBaseUrl = 'https://api.curseforge.com/v1';
  static const String _cfApiKey = '\$2a\$10\$nR2RmG2eXzAtR0c3T3xE0uvmF0VwG9fOqXzRzRzRzRzRzRzRzRzRA';
  static const String _defaultBaseUrl = 'https://mcbe-modpack-api.example.com';

  late String _baseUrl;

  ApiService() {
    _baseUrl = _defaultBaseUrl;
  }

  String get baseUrl => _baseUrl;
  String get cfBaseUrl => _cfBaseUrl;

  Map<String, String> get _cfHeaders => {
        'Accept': 'application/json',
        ApiConstants.cfApiKeyHeader: _cfApiKey,
      };

  Map<String, String> get _defaultHeaders => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  // ─── CurseForge Search ───────────────────────────────────────────────

  /// Search mods on CurseForge
  Future<SearchResult> searchMods({
    String query = '',
    String? category,
    int page = 0,
    int pageSize = 20,
    int classId = CfClassIds.mcbe,
    SortOption sort = SortOption.popular,
  }) async {
    final params = <String, String>{
      'gameId': ApiConstants.mcbeGameId,
      'index': page.toString(),
      'pageSize': pageSize.clamp(1, ApiConstants.maxPageSize).toString(),
      'sortField': sort.value,
      'sortOrder': 'desc',
    };

    if (query.isNotEmpty) {
      params['searchFilter'] = query;
    }

    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      final catId = CfCategoryIds.idFor(category);
      if (catId != null && catId > 0) {
        params['categoryId'] = catId.toString();
      }
    }

    final uri = Uri.parse('$_cfBaseUrl/mods/search').replace(queryParameters: params);

    final response = await http.get(uri, headers: _cfHeaders).timeout(
          const Duration(seconds: 15),
          onTimeout: () => http.Response('{"error":"timeout"}', 408),
        );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SearchResult.fromJson(json);
    } else {
      throw ApiException(
        'Failed to search mods',
        response.statusCode,
        response.body,
      );
    }
  }

  /// Get detailed information about a mod
  Future<CfModDetail> getModDetail(int modId) async {
    final uri = Uri.parse('$_cfBaseUrl/mods/$modId');

    final response = await http.get(uri, headers: _cfHeaders).timeout(
          const Duration(seconds: 15),
          onTimeout: () => http.Response('{"error":"timeout"}', 408),
        );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CfModDetail.fromJson(json);
    } else {
      throw ApiException(
        'Failed to load mod details',
        response.statusCode,
        response.body,
      );
    }
  }

  /// Get files for a mod with pagination
  Future<FilesResult> getModFiles({
    required int modId,
    int page = 0,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'index': page.toString(),
      'pageSize': pageSize.clamp(1, ApiConstants.maxPageSize).toString(),
    };

    final uri = Uri.parse('$_cfBaseUrl/mods/$modId/files').replace(queryParameters: params);

    final response = await http.get(uri, headers: _cfHeaders).timeout(
          const Duration(seconds: 15),
          onTimeout: () => http.Response('{"error":"timeout"}', 408),
        );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return FilesResult.fromJson(json);
    } else {
      throw ApiException(
        'Failed to load mod files',
        response.statusCode,
        response.body,
      );
    }
  }

  /// Get specific file info
  Future<CfFile> getFileInfo(int modId, int fileId) async {
    final uri = Uri.parse('$_cfBaseUrl/mods/$modId/files/$fileId');

    final response = await http.get(uri, headers: _cfHeaders).timeout(
          const Duration(seconds: 15),
          onTimeout: () => http.Response('{"error":"timeout"}', 408),
        );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CfFile.fromJson(json['data'] ?? json);
    } else {
      throw ApiException(
        'Failed to load file info',
        response.statusCode,
        response.body,
      );
    }
  }

  /// Get download URL for a specific file
  Future<String> getDownloadUrl(int modId, int fileId) async {
    final uri = Uri.parse('$_cfBaseUrl/mods/$modId/files/$fileId/download-url');

    final response = await http.get(uri, headers: _cfHeaders).timeout(
          const Duration(seconds: 15),
          onTimeout: () => http.Response('{"error":"timeout"}', 408),
        );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['data']?.toString() ?? '';
    } else {
      throw ApiException(
        'Failed to get download URL',
        response.statusCode,
        response.body,
      );
    }
  }

  /// Get categories for MCBE mods
  Future<List<CfCategory>> getCategories() async {
    final params = <String, String>{
      'gameId': ApiConstants.mcbeGameId,
    };

    final uri =
        Uri.parse('$_cfBaseUrl/categories').replace(queryParameters: params);

    final response = await http.get(uri, headers: _cfHeaders).timeout(
          const Duration(seconds: 15),
          onTimeout: () => http.Response('{"error":"timeout"}', 408),
        );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = json['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => CfCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(
        'Failed to load categories',
        response.statusCode,
        response.body,
      );
    }
  }

  // ─── Verification API ────────────────────────────────────────────────

  /// Get verification status for a single mod
  Future<VerificationStatus> getVerificationStatus(int modId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/mods/$modId/verification');

      final response = await http.get(uri, headers: _defaultHeaders).timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response('{"error":"timeout"}', 408),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return VerificationStatus.fromJson(json);
      }
    } catch (_) {}
    return const VerificationStatus(verified: false);
  }

  /// Get verification status for multiple mods at once
  Future<List<int>> getBatchVerificationStatus(List<int> modIds) async {
    if (modIds.isEmpty) return [];
    try {
      final uri = Uri.parse('$_baseUrl/api/mods/verification/batch');

      final response = await http.post(
        uri,
        headers: _defaultHeaders,
        body: jsonEncode({'modIds': modIds}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('{"error":"timeout"}', 408),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final ids = json['verifiedIds'] as List<dynamic>? ?? [];
        return ids.map((e) => e as int).toList();
      }
    } catch (_) {}
    return [];
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  const ApiException(this.message, [this.statusCode, this.body]);

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
