import 'package:flutter_test/flutter_test.dart';
import 'package:modpack_mcbe/models/mod.dart';
import 'package:modpack_mcbe/models/modpack.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ModpackService (unit tests)', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('SharedPreferences should be available', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs, isNotNull);
    });

    test('Modpack JSON round-trip', () async {
      final modpack = Modpack(
        id: 'mp_test',
        name: 'Test Modpack',
        description: 'A test modpack',
        mods: [
          Mod(id: '1', name: 'Mod 1', author: 'Author', downloads: 100),
          Mod(id: '2', name: 'Mod 2', author: 'Author', downloads: 200),
        ],
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // Serialize
      final json = modpack.toJson();
      expect(json['id'], 'mp_test');
      expect(json['mods'] as List, hasLength(2));

      // Deserialize
      final restored = Modpack.fromJson(json);
      expect(restored.id, 'mp_test');
      expect(restored.name, 'Test Modpack');
      expect(restored.mods.length, 2);
      expect(restored.hasMod('1'), true);
      expect(restored.hasMod('3'), false);
    });
  });

  group('VerificationStatus', () {
    test('should default to unverified', () {
      const status = VerificationStatus();
      expect(status.verified, false);
    });

    test('should parse from JSON', () {
      final json = {
        'verified': true,
        'verifiedBy': 'admin',
        'verifiedAt': '2024-01-15T10:00:00Z',
      };

      final status = VerificationStatus.fromJson(json);
      expect(status.verified, true);
      expect(status.verifiedBy, 'admin');
    });
  });

  group('ApiError', () {
    test('should format error message', () {
      final error = ApiError(statusCode: 404, message: 'Not found');
      expect(error.toString(), 'Error 404');
    });

    test('should use custom message if provided', () {
      final error = ApiError(statusCode: 500, message: 'Server error');
      expect(error.toString(), 'Server error');
    });
  });
}
