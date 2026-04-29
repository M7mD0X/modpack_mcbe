import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mod.dart';
import '../models/modpack.dart';
import '../services/modpack_service.dart';
import '../theme/app_theme.dart';

class AddToModpackSheet extends StatelessWidget {
  final Mod mod;

  const AddToModpackSheet({super.key, required this.mod});

  static Future<void> show(BuildContext context, Mod mod) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToModpackSheet(mod: mod),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modpackService = context.watch<ModpackService>();
    final modpacks = modpackService.modpacks;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Row(
              children: [
                Icon(
                  Icons.add_to_photos_rounded,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Add to Modpack',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Modpack list
          if (modpacks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXxl),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_off_outlined,
                    size: 48,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'No modpacks yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create a modpack first',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                  vertical: AppTheme.spacingSm,
                ),
                itemCount: modpacks.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final modpack = modpacks[index];
                  final isIn = modpack.hasMod(mod.id);

                  return _ModpackListTile(
                    modpack: modpack,
                    isAdded: isIn,
                    onTap: isIn
                        ? null
                        : () {
                            modpackService.addModToModpack(modpack.id, mod);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added to ${modpack.name}'),
                                backgroundColor: AppTheme.success,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context);
                          },
                  );
                },
              ),
            ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }
}

class _ModpackListTile extends StatelessWidget {
  final Modpack modpack;
  final bool isAdded;
  final VoidCallback? onTap;

  const _ModpackListTile({
    required this.modpack,
    required this.isAdded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isAdded
                    ? AppTheme.primary.withOpacity(0.12)
                    : AppTheme.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(
                isAdded ? Icons.check_circle : Icons.folder_outlined,
                color: isAdded ? AppTheme.primary : AppTheme.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modpack.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${modpack.mods.length} mod${modpack.mods.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            if (isAdded)
              Text(
                'Added',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              )
            else
              Icon(
                Icons.add_circle_outline_rounded,
                color: AppTheme.textMuted,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
