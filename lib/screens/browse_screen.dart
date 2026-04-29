import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_types.dart';
import '../models/cf_mod.dart';
import '../models/mod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/modpack_service.dart';
import '../theme/app_theme.dart';
import '../widgets/add_to_modpack_sheet.dart';
import '../widgets/category_filter.dart';
import '../widgets/fade_in_view.dart';
import '../widgets/mod_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/skeleton.dart';
import 'login_screen.dart';
import 'mod_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<CfMod> _mods = [];
  String _selectedCategory = 'All';
  SortOption _sortOption = SortOption.popular;
  int _currentPage = 0;
  int _totalResults = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isSearching = false;

  static const List<String> _categories = [
    'All',
    'Mobs',
    'Weapons',
    'Tools',
    'Biomes',
    'Blocks',
    'Armor',
    'Vehicles',
    'Magic',
    'Furniture',
    'Survival',
    'Adventure',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMods();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMods({bool reset = true}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _currentPage = 0;
        _mods = [];
      });
    }

    try {
      final result = await _apiService.searchMods(
        query: _searchController.text,
        category: _selectedCategory,
        page: reset ? 0 : _currentPage,
        pageSize: 20,
        sort: _sortOption,
      );

      setState(() {
        if (reset) {
          _mods = result.mods;
        } else {
          _mods = [..._mods, ...result.mods];
        }
        _totalResults = result.totalResults;
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _loadMore() {
    if (_isLoadingMore || _isLoading || _hasError) return;
    if ((_currentPage + 1) * 20 >= _totalResults) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    _loadMods(reset: false);
  }

  void _onSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    _loadMods();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadMods();
  }

  void _onSortChanged(SortOption? option) {
    if (option == null || option == _sortOption) return;
    setState(() {
      _sortOption = option;
    });
    _loadMods();
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Text(
                'Sort By',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ...SortOption.values.map((option) => ListTile(
                  title: Text(option.label),
                  trailing: _sortOption == option
                      ? Icon(Icons.check_rounded, color: AppTheme.primary)
                      : null,
                  onTap: () {
                    _onSortChanged(option);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: AppTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  void _onRefresh() {
    _loadMods();
  }

  void _navigateToDetail(CfMod mod) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModDetailScreen(modId: mod.id),
      ),
    );
  }

  void _showAccountMenu() {
    final auth = context.read<AuthService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User info or login prompt
            if (auth.isAuthenticated) ...[
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primary.withOpacity(0.15),
                      child: Text(
                        auth.user!.username.isNotEmpty
                            ? auth.user!.username[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.user!.username,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          auth.user!.email,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout_rounded, color: AppTheme.destructive),
                title: Text('Log Out',
                    style: TextStyle(color: AppTheme.destructive)),
                onTap: () {
                  auth.logout();
                  Navigator.pop(context);
                },
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingXl),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 48,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      'Sign in to sync your modpacks',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Sign In'),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],
            const SizedBox(height: AppTheme.spacingSm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.primary,
        backgroundColor: AppTheme.card,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingLg,
                  AppTheme.spacingLg + 8,
                  AppTheme.spacingSm,
                  0,
                ),
                child: Row(
                  children: [
                    Text(
                      'Browse',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _showSortMenu,
                      icon: Icon(Icons.sort_rounded, color: AppTheme.textSecondary),
                      tooltip: 'Sort',
                    ),
                    IconButton(
                      onPressed: _showAccountMenu,
                      icon: Icon(Icons.person_outline_rounded,
                          color: AppTheme.textSecondary),
                      tooltip: 'Account',
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                  vertical: AppTheme.spacingSm,
                ),
                child: SearchBarWidget(
                  controller: _searchController,
                  onSubmitted: _onSearch,
                  onClear: () => _loadMods(),
                ),
              ),
            ),

            // Category filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingSm,
                ),
                child: CategoryFilter(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onSelected: _onCategorySelected,
                ),
              ),
            ),

            // Results count
            if (!_isLoading && _mods.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                    vertical: AppTheme.spacingSm,
                  ),
                  child: Text(
                    '$_totalResults result${_totalResults != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                ),
              ),

            // Content
            if (_isLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                      child: SkeletonModCard(),
                    ),
                    childCount: 8,
                  ),
                ),
              )
            else if (_hasError)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingXl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 56,
                          color: AppTheme.destructive,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          'Something went wrong',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Text(
                          _errorMessage,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.spacingLg),
                        FilledButton.icon(
                          onPressed: _onRefresh,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_mods.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingXl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 56,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          _isSearching ? 'No results found' : 'No mods found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Text(
                          _isSearching
                              ? 'Try different keywords or filters'
                              : 'Pull down to refresh',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final mod = _mods[index];
                      final modpackService = context.watch<ModpackService>();

                      return FadeInView(
                        delay: Duration(milliseconds: index * 50),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppTheme.spacingSm,
                          ),
                          child: ModCard(
                            mod: Mod(
                              id: mod.id.toString(),
                              name: mod.name,
                              author: '',
                              description: mod.summary,
                              downloads: mod.downloadCount,
                              source: 'curseforge',
                            ),
                            onTap: () => _navigateToDetail(mod),
                            onAdd: () {
                              AddToModpackSheet.show(
                                context,
                                Mod(
                                  id: mod.id.toString(),
                                  name: mod.name,
                                  author: '',
                                  description: mod.summary,
                                  downloads: mod.downloadCount,
                                  source: 'curseforge',
                                ),
                              );
                            },
                            isInModpack: modpackService.isModInAnyModpack(
                                  mod.id.toString(),
                                ).isNotEmpty,
                          ),
                        ),
                      );
                    },
                    childCount: _mods.length +
                        (_isLoadingMore ? 3 : 0), // Extra items for loading indicator
                  ),
                ),
              ),

            // Loading more indicator
            if (_isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacingLg),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }
}
