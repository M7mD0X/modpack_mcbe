import 'package:flutter/material.dart';

import '../models/mod.dart';
import '../theme/app_theme.dart';
import 'mod_image.dart';
import 'verified_badge.dart';

class ModCard extends StatelessWidget {
  final Mod mod;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final bool showRemove;
  final bool isInModpack;
  final bool showVerified;

  const ModCard({
    super.key,
    required this.mod,
    this.onTap,
    this.onAdd,
    this.onRemove,
    this.showRemove = false,
    this.isInModpack = false,
    this.showVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mod image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: ModImage(
                    imageUrl: mod.imageUrl,
                    fallbackLetter: mod.name.isNotEmpty ? mod.name[0] : '?',
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mod.name,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (mod.source == 'curseforge')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.curseforgeBadge,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'CF',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9,
                                  ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        if (showVerified)
                          const VerifiedBadge(),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Author
                    Text(
                      mod.author,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Description
                    Text(
                      mod.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Stats row
                    Row(
                      children: [
                        if (mod.downloads > 0) ...[
                          Icon(
                            Icons.download_rounded,
                            size: 12,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _formatNumber(mod.downloads),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppTheme.textMuted),
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                        ],
                        if (mod.category.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              mod.category,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.accent,
                                    fontSize: 10,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                        ],
                        // Action button
                        if (showRemove)
                          SizedBox(
                            height: 28,
                            child: OutlinedButton.icon(
                              onPressed: onRemove,
                              icon: const Icon(Icons.remove, size: 14),
                              label: const Text('Remove'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.destructive,
                                side: BorderSide(color: AppTheme.destructive),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 28,
                            child: FilledButton.icon(
                              onPressed: isInModpack ? null : onAdd,
                              icon: Icon(
                                isInModpack ? Icons.check : Icons.add,
                                size: 14,
                              ),
                              label: Text(isInModpack ? 'Added' : 'Add'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '${(n / 1000000).toStringAsFixed(1)}M';
  }
}
