import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/api_types.dart';
import '../models/cf_mod.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/add_to_modpack_sheet.dart';
import '../widgets/mod_image.dart';
import '../widgets/verified_badge.dart';

class ModDetailScreen extends StatefulWidget {
  final int modId;

  const ModDetailScreen({super.key, required this.modId});

  @override
  State<ModDetailScreen> createState() => _ModDetailScreenState();
}

class _ModDetailScreenState extends State<ModDetailScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  CfModDetail? _modDetail;
  VerificationStatus _verificationStatus = const VerificationStatus();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  late TabController _tabController;

  // Files pagination
  List<CfFile> _files = [];
  int _filesPage = 0;
  bool _hasMoreFiles = true;
  bool _isLoadingFiles = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadModDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadModDetail() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final detail = await _apiService.getModDetail(widget.modId);
      final verification =
          await _apiService.getVerificationStatus(widget.modId);

      if (mounted) {
        setState(() {
          _modDetail = detail;
          _verificationStatus = verification;
          _isLoading = false;
        });

        // Load initial files
        _loadFiles();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoadingFiles = true;
    });

    try {
      final result = await _apiService.getModFiles(
        modId: widget.modId,
        page: _filesPage,
        pageSize: 20,
      );

      setState(() {
        _files = [..._files, ...result.files];
        _hasMoreFiles = result.hasMore;
        _isLoadingFiles = false;
      });
    } catch (_) {
      setState(() {
        _isLoadingFiles = false;
      });
    }
  }

  void _onAddToModpack() {
    if (_modDetail == null) return;
    AddToModpackSheet.show(context, _modDetail!.toMod());
  }

  Future<void> _openDownloadUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: _modDetail != null ? Text(_modDetail!.name) : null,
        actions: [
          if (_modDetail != null)
            IconButton(
              onPressed: _onAddToModpack,
              icon: Icon(Icons.add_to_photos_rounded, color: AppTheme.primary),
              tooltip: 'Add to modpack',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _hasError
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: AppTheme.destructive),
            const SizedBox(height: AppTheme.spacingMd),
            Text('Failed to load mod', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              _errorMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            FilledButton(
              onPressed: _loadModDetail,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final mod = _modDetail!;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: AppTheme.background,
            flexibleSpace: FlexibleSpaceBar(
              background: mod.imageUrl.isNotEmpty
                  ? ModImage(
                      imageUrl: mod.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      color: AppTheme.card,
                      child: Center(
                        child: Icon(
                          Icons.extension_rounded,
                          size: 64,
                          color: AppTheme.textMuted.withOpacity(0.3),
                        ),
                      ),
                    ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'About'),
                Tab(text: 'Versions'),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAboutTab(mod),
          _buildVersionsTab(),
        ],
      ),
    );
  }

  Widget _buildAboutTab(CfModDetail mod) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      children: [
        // Name and badges
        Row(
          children: [
            Expanded(
              child: Text(
                mod.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            if (true) // curseforge source
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.curseforgeBadge,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'CF',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            const SizedBox(width: 8),
            if (_verificationStatus.verified) const VerifiedBadge(size: 22),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),

        // Author
        Text(
          'By ${mod.primaryAuthor.isNotEmpty ? mod.primaryAuthor : "Unknown"}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: AppTheme.spacingLg),

        // Stats row
        Row(
          children: [
            _StatItem(
              icon: Icons.download_rounded,
              label: 'Downloads',
              value: mod.formattedDownloads,
            ),
            const SizedBox(width: AppTheme.spacingXl),
            if (mod.dateCreated != null)
              _StatItem(
                icon: Icons.calendar_today_rounded,
                label: 'Created',
                value: _formatDate(mod.dateCreated!),
              ),
            const SizedBox(width: AppTheme.spacingXl),
            if (mod.formattedDate.isNotEmpty)
              _StatItem(
                icon: Icons.update_rounded,
                label: 'Updated',
                value: mod.formattedDate,
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXl),

        // Categories
        if (mod.categories.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mod.categories
                .take(6)
                .map((cat) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        cat,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.accent,
                                ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppTheme.spacingXl),
        ],

        // Description
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          mod.description ?? mod.summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
        ),

        const SizedBox(height: AppTheme.spacingXxl),

        // Screenshots
        if (mod.screenshots.length > 1) ...[
          Text(
            'Screenshots',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: mod.screenshots.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppTheme.spacingSm),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: ModImage(
                    imageUrl: mod.screenshots[index],
                    width: 220,
                    height: 160,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingXxl),
        ],

        // Download button
        if (mod.latestFiles.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                final file = mod.latestFiles.first;
                if (file.downloadUrl.isNotEmpty) {
                  _openDownloadUrl(file.downloadUrl);
                }
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download Latest'),
            ),
          ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildVersionsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      children: [
        if (_files.isEmpty && !_isLoadingFiles)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              child: Column(
                children: [
                  Icon(Icons.history_rounded, size: 48, color: AppTheme.textMuted),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'No versions available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._files.map((file) => _FileTile(
                file: file,
                onDownload: () async {
                  try {
                    final url = await _apiService.getDownloadUrl(
                        widget.modId, file.id);
                    if (url.isNotEmpty) _openDownloadUrl(url);
                  } catch (_) {}
                },
              )),

        if (_isLoadingFiles)
          const Padding(
            padding: EdgeInsets.all(AppTheme.spacingLg),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          ),

        if (_hasMoreFiles && !_isLoadingFiles)
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Center(
              child: TextButton(
                onPressed: () {
                  setState(() => _filesPage++);
                  _loadFiles();
                },
                child: const Text('Load more'),
              ),
            ),
          ),

        const SizedBox(height: 40),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _FileTile extends StatelessWidget {
  final CfFile file;
  final VoidCallback? onDownload;

  const _FileTile({required this.file, this.onDownload});

  @override
  Widget build(BuildContext context) {
    final releaseColor = file.releaseType == 'release'
        ? AppTheme.success
        : file.releaseType == 'beta'
            ? AppTheme.warning
            : AppTheme.info;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: releaseColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  file.releaseType.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: releaseColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  file.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // File info
          Wrap(
            spacing: AppTheme.spacingMd,
            runSpacing: 4,
            children: [
              Text(
                file.formattedSize,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
              ),
              Text(
                '${file.formattedDownloads} downloads',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
              ),
              if (file.fileDate != null)
                Text(
                  _formatDate(file.fileDate!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
            ],
          ),
          if (file.gameVersions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: file.gameVersions
                  .take(5)
                  .map((v) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          v,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(fontSize: 10),
                        ),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: AppTheme.spacingSm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Download'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
