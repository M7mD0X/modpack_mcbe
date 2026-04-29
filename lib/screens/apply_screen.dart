import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/modpack_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_in_view.dart';

class ApplyScreen extends StatefulWidget {
  const ApplyScreen({super.key});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen>
    with AutomaticKeepAliveClientMixin {
  String _applyingModpackId = '';
  @override
  bool get wantKeepAlive => true;

  Future<void> _applyModpack(String modpackId) async {
    setState(() {
      _applyingModpackId = modpackId;
    });

    // Simulate the apply process
    // In a real implementation, this would use platform channels to
    // import mods into the Minecraft installation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _applyingModpackId = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Modpack applied successfully!'),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final modpackService = context.watch<ModpackService>();
    final applicable = modpackService.applicableModpacks;

    return Scaffold(
      backgroundColor: AppTheme.background,
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
              child: Text(
                'Apply',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),

          // Info banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: AppTheme.info.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.info,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text(
                        'Tap on a modpack to import its mods into Minecraft Bedrock Edition. '
                        'Make sure Minecraft is installed on your device.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingLg)),

          // Content
          if (applicable.isEmpty)
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
                          color: AppTheme.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 40,
                          color: AppTheme.warning.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      Text(
                        'No modpacks to apply',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        'Create a modpack and add some mods first.\n'
                        'Then come back here to apply it.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                        textAlign: TextAlign.center,
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
                    final modpack = applicable[index];
                    final isApplying = _applyingModpackId == modpack.id;

                    return FadeInView(
                      delay: Duration(milliseconds: index * 60),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppTheme.spacingSm,
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: InkWell(
                            onTap: isApplying
                                ? null
                                : () => _applyModpack(modpack.id),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLg),
                            child: Padding(
                              padding: const EdgeInsets.all(AppTheme.spacingMd),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMd),
                                    ),
                                    child: isApplying
                                        ? Padding(
                                            padding: const EdgeInsets.all(12),
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: AppTheme.primary,
                                            ),
                                          )
                                        : Icon(
                                            Icons.play_arrow_rounded,
                                            color: AppTheme.primary,
                                            size: 28,
                                          ),
                                  ),
                                  const SizedBox(
                                      width: AppTheme.spacingMd),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          modpack.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${modpack.mods.length} mod${modpack.mods.length != 1 ? 's' : ''}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppTheme.textMuted,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: applicable.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}
