import 'mod.dart';

class Modpack {
  final String id;
  final String name;
  final String description;
  final List<Mod> mods;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Modpack({
    required this.id,
    required this.name,
    this.description = '',
    this.mods = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Modpack.fromJson(Map<String, dynamic> json) {
    return Modpack(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      mods: (json['mods'] as List<dynamic>?)
              ?.map((e) => Mod.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'mods': mods.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Modpack copyWith({
    String? id,
    String? name,
    String? description,
    List<Mod>? mods,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Modpack(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mods: mods ?? this.mods,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool hasMod(String modId) {
    return mods.any((m) => m.id == modId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Modpack && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
