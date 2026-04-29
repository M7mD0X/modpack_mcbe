import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mod.dart';
import '../services/modpack_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_in_view.dart';
import '../widgets/mod_card.dart';
import 'browse_screen.dart';
import 'mod_detail_screen.dart';

class ModpackDetailScreen extends StatelessWidget {
  final String modpackId;

  const ModpackDetailScreen({super.key, required this.modpackId});

  @override
  Widget build(BuildContext context) {
    final modpackService = context.watch<ModpackService>();
    final modpack = modpackService.getModpack(modpackId);

    if (modpack == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Modpack')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 56, color: AppTheme.textMuted),
              const SizedBox(height: AppTheme.spacingMd),
              Text('Modpack not found',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppTheme.spacingLg),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(modpack.name),
        actions: [
          if (modpack.mods.isNotEmpty)
            IconButton(
              onPressed: () => _applyModpack(context),
              icon: Icon(Icons.play_arrow_rounded, color: AppTheme.primary),
              tooltip: 'Apply modpack',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Icon(
                  Icons.folder_special,
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modpack.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${modpack.mods.length} mod${modpack.mods.length != 1 ? 's' : ''} • '
                      'Created ${_formatDate(modpack.createdAt)}',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Description
          if (modpack.description.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              modpack.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],

          const SizedBox(height: AppTheme.spacingXl),
          const Divider(),
          const SizedBox(height: AppTheme.spacingSm),

          // Mods section header
          Row(
            children: [
              Text(
                'Mods',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '${modpack.mods.length}',
                  style:
                      Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                ),
              ),
            ],
          ),

          // Mod list
          if (modpack.mods.isEmpty) ...[
            const SizedBox(height: AppTheme.spacingXxl),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.add_box_outlined,
                    size: 48,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'No mods yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainNavigation()),
                        (route) => route.isFirst,
                      );
                    },
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Browse Mods'),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: AppTheme.spacingMd),
            ...modpack.mods.asMap().entries.map((entry) {
              final index = entry.key;
              final mod = entry.value;
              return FadeInView(
                delay: Duration(milliseconds: index * 50),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                  child: ModCard(
                    mod: mod,
                    showRemove: true,
                    showVerified: true,
                    onTap: () {
                      // Navigate to mod detail if it has a numeric ID
                      final modId = int.tryParse(mod.id);
                      if (modId != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ModDetailScreen(modId: modId),
                          ),
                        );
                      }
                    },
                    onRemove: () => _confirmRemoveMod(context, modpack.id, mod),
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _confirmRemoveMod(BuildContext context, String modpackId, Mod mod) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          side: BorderSide(color: AppTheme.border, width: 0.5),
        ),
        title: Text(
          'Remove Mod',
          style: Theme.of(dialogContext).textTheme.titleMedium,
        ),
        content: Text(
          'Remove "${mod.name}" from this modpack?',
          style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context
                  .read<ModpackService>()
                  .removeModFromModpack(modpackId, mod.id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed ${mod.name}'),
                  backgroundColor: AppTheme.warning,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.destructive),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _applyModpack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Applying modpack...'),
        backgroundColor: AppTheme.info,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Helper: A widget wrapping the bottom navigation for navigation reset
class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrowseScreen();
  }
}
