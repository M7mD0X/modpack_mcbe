import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/modpack_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_in_view.dart';
import '../widgets/modpack_card.dart';
import '../widgets/skeleton.dart';
import 'create_modpack_screen.dart';
import 'modpack_detail_screen.dart';

class ModpacksScreen extends StatefulWidget {
  const ModpacksScreen({super.key});

  @override
  State<ModpacksScreen> createState() => _ModpacksScreenState();
}

class _ModpacksScreenState extends State<ModpacksScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _navigateToCreate() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateModpackScreen()),
    );
    if (result == true) {
      context.read<ModpackService>().reload();
    }
  }

  void _navigateToDetail(String modpackId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModpackDetailScreen(modpackId: modpackId),
      ),
    );
  }

  void _confirmDelete(String modpackId, String modpackName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          side: BorderSide(color: AppTheme.border, width: 0.5),
        ),
        title: Text(
          'Delete Modpack',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(
          'Are you sure you want to delete "$modpackName"? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ModpackService>().deleteModpack(modpackId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted $modpackName'),
                  backgroundColor: AppTheme.destructive,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.destructive,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final modpackService = context.watch<ModpackService>();
    final modpacks = modpackService.modpacks;

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                AppTheme.spacingLg + 8,
                AppTheme.spacingLg,
                AppTheme.spacingMd,
              ),
              child: Row(
                children: [
                  Text(
                    'Modpacks',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  if (modpacks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        '${modpacks.length}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          if (modpackService.isLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                    child: SkeletonModpackCard(),
                  ),
                  childCount: 6,
                ),
              ),
            )
          else if (modpacks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingXl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.folder_off_outlined,
                          size: 40,
                          color: AppTheme.accent.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      Text(
                        'No modpacks yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        'Create your first modpack to organize\nyour favorite Minecraft BE mods',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingXl),
                      FilledButton.icon(
                        onPressed: _navigateToCreate,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Create Modpack'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final modpack = modpacks[index];
                    return FadeInView(
                      delay: Duration(milliseconds: index * 60),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppTheme.spacingSm,
                        ),
                        child: ModpackCard(
                          modpack: modpack,
                          onTap: () => _navigateToDetail(modpack.id),
                          onDelete: () =>
                              _confirmDelete(modpack.id, modpack.name),
                        ),
                      ),
                    );
                  },
                  childCount: modpacks.length,
                ),
              ),
            ),

          // Bottom padding (for FAB)
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}
