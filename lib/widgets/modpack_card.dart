import 'package:flutter/material.dart';

import '../models/modpack.dart';
import '../theme/app_theme.dart';

class ModpackCard extends StatelessWidget {
  final Modpack modpack;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final VoidCallback? onDelete;

  const ModpackCard({
    super.key,
    required this.modpack,
    this.onTap,
    this.onApply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasMods = modpack.mods.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasMods
                      ? AppTheme.primary.withOpacity(0.12)
                      : AppTheme.textMuted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(
                  hasMods ? Icons.folder_special : Icons.folder_outlined,
                  color: hasMods ? AppTheme.primary : AppTheme.textMuted,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modpack.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      modpack.description.isNotEmpty
                          ? modpack.description
                          : '${modpack.mods.length} mod${modpack.mods.length != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Mod count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: hasMods
                      ? AppTheme.primary.withOpacity(0.12)
                      : AppTheme.cardHover,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '${modpack.mods.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: hasMods ? AppTheme.primary : AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              // Actions
              if (hasMods && onApply != null)
                IconButton(
                  onPressed: onApply,
                  icon: Icon(
                    Icons.play_arrow_rounded,
                    color: AppTheme.primary,
                  ),
                  tooltip: 'Apply modpack',
                  iconSize: 28,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.destructive.withOpacity(0.7),
                  ),
                  tooltip: 'Delete modpack',
                  iconSize: 22,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
