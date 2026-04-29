class Mod {
  final String id;
  final String name;
  final String author;
  final String description;
  final String longDescription;
  final String category;
  final int downloads;
  final int rating;
  final String version;
  final String mcVersion;
  final String imageUrl;
  final List<String> screenshots;
  final String fileSize;
  final String source;
  final String downloadUrl;
  final String updatedAt;
  final List<String> tags;
  final int? latestFileId;

  const Mod({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
    this.longDescription = '',
    this.category = '',
    this.downloads = 0,
    this.rating = 0,
    this.version = '',
    this.mcVersion = '',
    this.imageUrl = '',
    this.screenshots = const [],
    this.fileSize = '',
    this.source = 'curseforge',
    this.downloadUrl = '',
    this.updatedAt = '',
    this.tags = const [],
    this.latestFileId,
  });

  factory Mod.fromJson(Map<String, dynamic> json) {
    return Mod(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      longDescription: json['longDescription']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      downloads: json['downloads'] is int ? json['downloads'] as int : 0,
      rating: json['rating'] is int ? json['rating'] as int : 0,
      version: json['version']?.toString() ?? '',
      mcVersion: json['mcVersion']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      screenshots: (json['screenshots'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      fileSize: json['fileSize']?.toString() ?? '',
      source: json['source']?.toString() ?? 'curseforge',
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      latestFileId: json['latestFileId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'description': description,
      'longDescription': longDescription,
      'category': category,
      'downloads': downloads,
      'rating': rating,
      'version': version,
      'mcVersion': mcVersion,
      'imageUrl': imageUrl,
      'screenshots': screenshots,
      'fileSize': fileSize,
      'source': source,
      'downloadUrl': downloadUrl,
      'updatedAt': updatedAt,
      'tags': tags,
      'latestFileId': latestFileId,
    };
  }

  Mod copyWith({
    String? id,
    String? name,
    String? author,
    String? description,
    String? longDescription,
    String? category,
    int? downloads,
    int? rating,
    String? version,
    String? mcVersion,
    String? imageUrl,
    List<String>? screenshots,
    String? fileSize,
    String? source,
    String? downloadUrl,
    String? updatedAt,
    List<String>? tags,
    int? latestFileId,
  }) {
    return Mod(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      description: description ?? this.description,
      longDescription: longDescription ?? this.longDescription,
      category: category ?? this.category,
      downloads: downloads ?? this.downloads,
      rating: rating ?? this.rating,
      version: version ?? this.version,
      mcVersion: mcVersion ?? this.mcVersion,
      imageUrl: imageUrl ?? this.imageUrl,
      screenshots: screenshots ?? this.screenshots,
      fileSize: fileSize ?? this.fileSize,
      source: source ?? this.source,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      latestFileId: latestFileId ?? this.latestFileId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mod && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
