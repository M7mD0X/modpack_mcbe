import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mod.dart';
import '../models/modpack.dart';

/// Modpack service for managing local modpacks stored in SharedPreferences.
class ModpackService with ChangeNotifier {
  static const String _storageKey = 'modpacks';
  final SharedPreferences _prefs;

  List<Modpack> _modpacks = [];
  bool _isLoading = false;

  List<Modpack> get modpacks => List.unmodifiable(_modpacks);
  bool get isLoading => _isLoading;
  int get modpackCount => _modpacks.length;

  ModpackService(this._prefs) {
    _loadModpacks();
  }

  // ─── Storage ─────────────────────────────────────────────────────────

  Future<void> _loadModpacks() async {
    _isLoading = true;
    try {
      final jsonStr = _prefs.getString(_storageKey);
      if (jsonStr != null) {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        _modpacks = list
            .map((e) => Modpack.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _modpacks = [];
      }
    } catch (e) {
      debugPrint('Failed to load modpacks: $e');
      _modpacks = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveModpacks() async {
    try {
      final jsonStr = jsonEncode(_modpacks.map((m) => m.toJson()).toList());
      await _prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      debugPrint('Failed to save modpacks: $e');
    }
  }

  // ─── CRUD ────────────────────────────────────────────────────────────

  /// Create a new modpack
  Modpack createModpack(String name, {String description = ''}) {
    final now = DateTime.now();
    final modpack = Modpack(
      id: 'mp_${now.millisecondsSinceEpoch}',
      name: name.trim(),
      description: description.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _modpacks = [..._modpacks, modpack];
    _saveModpacks();
    notifyListeners();
    return modpack;
  }

  /// Delete a modpack by ID
  void deleteModpack(String id) {
    _modpacks = _modpacks.where((m) => m.id != id).toList();
    _saveModpacks();
    notifyListeners();
  }

  /// Update modpack name/description
  void updateModpack(String id, {String? name, String? description}) {
    final index = _modpacks.indexWhere((m) => m.id == id);
    if (index == -1) return;

    _modpacks[index] = _modpacks[index].copyWith(
      name: name != null ? name.trim() : null,
      description: description != null ? description.trim() : null,
      updatedAt: DateTime.now(),
    );
    _saveModpacks();
    notifyListeners();
  }

  /// Get a modpack by ID
  Modpack? getModpack(String id) {
    try {
      return _modpacks.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Mod Management ──────────────────────────────────────────────────

  /// Add a mod to a modpack (prevents duplicates)
  bool addModToModpack(String modpackId, Mod mod) {
    final index = _modpacks.indexWhere((m) => m.id == modpackId);
    if (index == -1) return false;

    if (_modpacks[index].hasMod(mod.id)) return false; // Already added

    _modpacks[index] = _modpacks[index].copyWith(
      mods: [..._modpacks[index].mods, mod],
      updatedAt: DateTime.now(),
    );
    _saveModpacks();
    notifyListeners();
    return true;
  }

  /// Remove a mod from a modpack
  bool removeModFromModpack(String modpackId, String modId) {
    final index = _modpacks.indexWhere((m) => m.id == modpackId);
    if (index == -1) return false;

    final updatedMods = _modpacks[index].mods.where((m) => m.id != modId).toList();
    _modpacks[index] = _modpacks[index].copyWith(
      mods: updatedMods,
      updatedAt: DateTime.now(),
    );
    _saveModpacks();
    notifyListeners();
    return true;
  }

  /// Check if a mod is in any modpack, return list of modpack IDs
  List<String> isModInAnyModpack(String modId) {
    return _modpacks
        .where((mp) => mp.hasMod(modId))
        .map((mp) => mp.id)
        .toList();
  }

  /// Check if a mod is already in a specific modpack
  bool isModInModpack(String modpackId, String modId) {
    final modpack = getModpack(modpackId);
    return modpack?.hasMod(modId) ?? false;
  }

  /// Get total mod count across all modpacks
  int get totalModCount {
    return _modpacks.fold(0, (sum, mp) => sum + mp.mods.length);
  }

  /// Get modpacks that have at least one mod (for apply tab)
  List<Modpack> get applicableModpacks {
    return _modpacks.where((mp) => mp.mods.isNotEmpty).toList();
  }

  /// Reload modpacks from storage
  Future<void> reload() async {
    await _loadModpacks();
  }
}
