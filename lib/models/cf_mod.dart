class CfFile {
  final int id;
  final String displayName;
  final String fileName;
  final int fileSize;
  final String releaseType;
  final int downloadCount;
  final DateTime? fileDate;
  final List<String> gameVersions;
  final String downloadUrl;
  final String? fileStatus;

  const CfFile({
    required this.id,
    required this.displayName,
    required this.fileName,
    required this.fileSize,
    required this.releaseType,
    required this.downloadCount,
    this.fileDate,
    this.gameVersions = const [],
    this.downloadUrl = '',
    this.fileStatus,
  });

  factory CfFile.fromJson(Map<String, dynamic> json) {
    return CfFile(
      id: json['id'] as int? ?? 0,
      displayName: json['displayName']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      fileSize: json['fileSize'] as int? ?? 0,
      releaseType: json['releaseType'] as int? == 1
          ? 'release'
          : json['releaseType'] as int? == 2
              ? 'beta'
              : json['releaseType'] as int? == 3
                  ? 'alpha'
                  : 'release',
      downloadCount: json['downloadCount'] as int? ?? 0,
      fileDate: json['fileDate'] != null
          ? DateTime.tryParse(json['fileDate'].toString())
          : null,
      gameVersions: (json['gameVersions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      fileStatus: json['fileStatus']?.toString(),
    );
  }

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedDownloads {
    if (downloadCount < 1000) return '$downloadCount';
    if (downloadCount < 1000000) {
      return '${(downloadCount / 1000).toStringAsFixed(1)}K';
    }
    return '${(downloadCount / 1000000).toStringAsFixed(1)}M';
  }
}

class CfMod {
  final int id;
  final String name;
  final String slug;
  final int? gameId;
  final String summary;
  final int downloadCount;
  final int? categoryId;

  const CfMod({
    required this.id,
    required this.name,
    this.slug = '',
    this.gameId,
    this.summary = '',
    this.downloadCount = 0,
    this.categoryId,
  });

  factory CfMod.fromJson(Map<String, dynamic> json) {
    return CfMod(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      gameId: json['gameId'] as int?,
      summary: json['summary']?.toString() ?? '',
      downloadCount: json['downloadCount'] as int? ?? 0,
      categoryId: json['categoryId'] as int?,
    );
  }

  String get formattedDownloads {
    if (downloadCount < 1000) return '$downloadCount';
    if (downloadCount < 1000000) {
      return '${(downloadCount / 1000).toStringAsFixed(1)}K';
    }
    return '${(downloadCount / 1000000).toStringAsFixed(1)}M';
  }
}

class CfModDetail {
  final int id;
  final String name;
  final String slug;
  final String summary;
  final int downloadCount;
  final String? description;
  final DateTime? dateCreated;
  final DateTime? dateModified;
  final DateTime? dateReleased;
  final List<String> categories;
  final List<CfFile> latestFiles;
  final List<String> screenshots;
  final String primaryAuthor;
  final int? primaryAuthorId;
  final List<String> links;

  const CfModDetail({
    required this.id,
    required this.name,
    this.slug = '',
    this.summary = '',
    this.downloadCount = 0,
    this.description,
    this.dateCreated,
    this.dateModified,
    this.dateReleased,
    this.categories = const [],
    this.latestFiles = const [],
    this.screenshots = const [],
    this.primaryAuthor = '',
    this.primaryAuthorId,
    this.links = const [],
  });

  factory CfModDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final authors = data['authors'] as List<dynamic>?;
    final primaryAuthorMap =
        (authors != null && authors.isNotEmpty) ? authors[0] as Map<String, dynamic> : null;

    return CfModDetail(
      id: data['id'] as int? ?? 0,
      name: data['name']?.toString() ?? '',
      slug: data['slug']?.toString() ?? '',
      summary: data['summary']?.toString() ?? '',
      downloadCount: data['downloadCount'] as int? ?? 0,
      description: data['description']?.toString(),
      dateCreated: data['dateCreated'] != null
          ? DateTime.tryParse(data['dateCreated'].toString())
          : null,
      dateModified: data['dateModified'] != null
          ? DateTime.tryParse(data['dateModified'].toString())
          : null,
      dateReleased: data['dateReleased'] != null
          ? DateTime.tryParse(data['dateReleased'].toString())
          : null,
      categories: (data['categories'] as List<dynamic>?)
              ?.map((e) => e['name']?.toString() ?? '')
              .toList() ??
          [],
      latestFiles: (data['latestFiles'] as List<dynamic>?)
              ?.map((e) => CfFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      screenshots: (data['screenshots'] as List<dynamic>?)
              ?.map((e) {
                final url = e is Map ? e['url']?.toString() : e.toString();
                return url ?? '';
              })
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      primaryAuthor: primaryAuthorMap?['name']?.toString() ?? '',
      primaryAuthorId: primaryAuthorMap?['id'] as int?,
      links: (data['links'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  String get imageUrl {
    if (screenshots.isNotEmpty) return screenshots.first;
    return '';
  }

  String get formattedDownloads {
    if (downloadCount < 1000) return '$downloadCount';
    if (downloadCount < 1000000) {
      return '${(downloadCount / 1000).toStringAsFixed(1)}K';
    }
    return '${(downloadCount / 1000000).toStringAsFixed(1)}M';
  }

  String get formattedDate {
    final d = dateModified ?? dateCreated;
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Convert to a Mod object
  Mod toMod() {
    final latestFile = latestFiles.isNotEmpty ? latestFiles.first : null;
    return Mod(
      id: id.toString(),
      name: name,
      author: primaryAuthor,
      description: summary,
      longDescription: description ?? '',
      category: categories.isNotEmpty ? categories.first : '',
      downloads: downloadCount,
      imageUrl: imageUrl,
      version: latestFile?.displayName ?? '',
      mcVersion: latestFile?.gameVersions.isNotEmpty == true
          ? latestFile!.gameVersions.first
          : '',
      fileSize: latestFile?.formattedSize ?? '',
      source: 'curseforge',
      updatedAt: formattedDate,
      tags: categories,
      latestFileId: latestFile?.id,
    );
  }
}

class SearchResult {
  final List<CfMod> mods;
  final int totalResults;
  final int pageSize;
  final int currentPage;

  const SearchResult({
    this.mods = const [],
    this.totalResults = 0,
    this.pageSize = 20,
    this.currentPage = 0,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      mods: (json['data'] as List<dynamic>?)
              ?.map((e) => CfMod.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalResults: json['pagination']?['totalCount'] as int? ?? 0,
      pageSize: json['pagination']?['pageSize'] as int? ?? 20,
      currentPage: json['pagination']?['index'] as int? ?? 0,
    );
  }

  bool get hasMore => (currentPage + 1) * pageSize < totalResults;
}

class FilesResult {
  final List<CfFile> files;
  final int totalResults;
  final int pageSize;
  final int currentPage;

  const FilesResult({
    this.files = const [],
    this.totalResults = 0,
    this.pageSize = 20,
    this.currentPage = 0,
  });

  factory FilesResult.fromJson(Map<String, dynamic> json) {
    return FilesResult(
      files: (json['data'] as List<dynamic>?)
              ?.map((e) => CfFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalResults: json['pagination']?['totalCount'] as int? ?? 0,
      pageSize: json['pagination']?['pageSize'] as int? ?? 20,
      currentPage: json['pagination']?['index'] as int? ?? 0,
    );
  }

  bool get hasMore => (currentPage + 1) * pageSize < totalResults;
}

class CfCategory {
  final int id;
  final String name;
  final String slug;
  final int? parentId;
  final String? iconUrl;
  final int modCount;

  const CfCategory({
    required this.id,
    required this.name,
    this.slug = '',
    this.parentId,
    this.iconUrl,
    this.modCount = 0,
  });

  factory CfCategory.fromJson(Map<String, dynamic> json) {
    return CfCategory(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      parentId: json['parentId'] as int?,
      iconUrl: json['iconUrl']?.toString(),
      modCount: json['gamePopularity'] as int? ?? 0,
    );
  }
}
