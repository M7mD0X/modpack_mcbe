import 'package:flutter_test/flutter_test.dart';
import 'package:modpack_mcbe/models/mod.dart';
import 'package:modpack_mcbe/models/modpack.dart';
import 'package:modpack_mcbe/models/auth_user.dart';
import 'package:modpack_mcbe/models/cf_mod.dart';
import 'package:modpack_mcbe/models/api_types.dart';

void main() {
  group('Mod Model', () {
    test('should create from JSON', () {
      final json = {
        'id': '123',
        'name': 'Test Mod',
        'author': 'TestAuthor',
        'description': 'A test mod',
        'downloads': 5000,
        'source': 'curseforge',
        'tags': ['tools', 'survival'],
      };

      final mod = Mod.fromJson(json);

      expect(mod.id, '123');
      expect(mod.name, 'Test Mod');
      expect(mod.author, 'TestAuthor');
      expect(mod.description, 'A test mod');
      expect(mod.downloads, 5000);
      expect(mod.source, 'curseforge');
      expect(mod.tags, ['tools', 'survival']);
    });

    test('should serialize to JSON', () {
      final mod = Mod(
        id: '456',
        name: 'Test Mod 2',
        author: 'Author2',
        description: 'Another mod',
        downloads: 1000,
      );

      final json = mod.toJson();

      expect(json['id'], '456');
      expect(json['name'], 'Test Mod 2');
      expect(json['author'], 'Author2');
      expect(json['description'], 'Another mod');
      expect(json['downloads'], 1000);
    });

    test('should copy with updated fields', () {
      final mod = Mod(
        id: '789',
        name: 'Original',
        author: 'Author',
        description: 'Original mod',
        downloads: 100,
      );

      final updated = mod.copyWith(name: 'Updated', downloads: 200);

      expect(updated.id, '789');
      expect(updated.name, 'Updated');
      expect(updated.downloads, 200);
    });

    test('should implement equality by id', () {
      const mod1 = Mod(id: '1', name: 'Mod A', author: 'Author', description: 'Desc');
      const mod2 = Mod(id: '1', name: 'Mod B', author: 'Author', description: 'Desc');
      const mod3 = Mod(id: '2', name: 'Mod A', author: 'Author', description: 'Desc');

      expect(mod1, equals(mod2));
      expect(mod1, isNot(equals(mod3)));
    });
  });

  group('Modpack Model', () {
    test('should create from JSON', () {
      final json = {
        'id': 'mp_1',
        'name': 'My Modpack',
        'description': 'Test modpack',
        'mods': [
          {
            'id': '1',
            'name': 'Mod 1',
            'author': 'Author',
            'description': 'Desc',
          },
        ],
        'createdAt': '2024-01-15T10:00:00.000Z',
        'updatedAt': '2024-01-15T10:00:00.000Z',
      };

      final modpack = Modpack.fromJson(json);

      expect(modpack.id, 'mp_1');
      expect(modpack.name, 'My Modpack');
      expect(modpack.mods.length, 1);
      expect(modpack.mods.first.name, 'Mod 1');
    });

    test('should check if mod is in modpack', () {
      final modpack = Modpack(
        id: 'mp_2',
        name: 'Test',
        mods: [
          Mod(id: '1', name: 'Mod 1', author: 'Author', description: 'Desc'),
          Mod(id: '2', name: 'Mod 2', author: 'Author', description: 'Desc'),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(modpack.hasMod('1'), true);
      expect(modpack.hasMod('3'), false);
    });
  });

  group('AuthUser Model', () {
    test('should create from JSON', () {
      final json = {
        'id': 'user_1',
        'username': 'testuser',
        'email': 'test@example.com',
        'emailVerified': true,
      };

      final user = AuthUser.fromJson(json);

      expect(user.id, 'user_1');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.emailVerified, true);
    });

    test('should copy with updated fields', () {
      final user = AuthUser(
        id: 'u1',
        username: 'user',
        email: 'user@example.com',
        emailVerified: false,
      );

      final verified = user.copyWith(emailVerified: true);
      expect(verified.emailVerified, true);
      expect(verified.id, 'u1');
    });
  });

  group('CfFile Model', () {
    test('should format file size correctly', () {
      expect(const CfFile(id: 0, displayName: '', fileName: '', fileSize: 500, releaseType: 'release', downloadCount: 0).formattedSize, '500 B');
      expect(const CfFile(id: 0, displayName: '', fileName: '', fileSize: 2048, releaseType: 'release', downloadCount: 0).formattedSize, '2.0 KB');
      expect(const CfFile(id: 0, displayName: '', fileName: '', fileSize: 5242880, releaseType: 'release', downloadCount: 0).formattedSize, '5.0 MB');
    });

    test('should format download count correctly', () {
      expect(const CfFile(id: 0, displayName: '', fileName: '', fileSize: 0, releaseType: 'release', downloadCount: 500).formattedDownloads, '500');
      expect(const CfFile(id: 0, displayName: '', fileName: '', fileSize: 0, releaseType: 'release', downloadCount: 15000).formattedDownloads, '15.0K');
      expect(const CfFile(id: 0, displayName: '', fileName: '', fileSize: 0, releaseType: 'release', downloadCount: 2500000).formattedDownloads, '2.5M');
    });
  });

  group('CfCategoryIds', () {
    test('should return correct IDs for known categories', () {
      expect(CfCategoryIds.idFor('mobs'), 423);
      expect(CfCategoryIds.idFor('weapons'), 421);
      expect(CfCategoryIds.idFor('all'), -1);
      expect(CfCategoryIds.idFor('unknown'), isNull);
    });
  });

  group('SortOption', () {
    test('should have correct values and labels', () {
      expect(SortOption.popular.value, 'popularity');
      expect(SortOption.popular.label, 'Popular');
      expect(SortOption.downloads.value, 'totalDownloads');
      expect(SortOption.newest.value, 'dateCreated');
    });
  });
}
