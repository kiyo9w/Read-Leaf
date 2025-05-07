import 'package:flutter/material.dart';
import 'package:read_leaf/features/characters/domain/models/ai_character.dart';
import 'package:read_leaf/features/characters/data/ai_character_service.dart';
import 'package:read_leaf/injection/injection.dart';
import 'package:read_leaf/features/characters/presentation/screens/create_character_screen.dart';
import 'package:read_leaf/features/characters/presentation/screens/import_character_screen.dart';
import 'package:read_leaf/features/library/presentation/screens/home_screen.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:read_leaf/nav_screen.dart';
import 'package:read_leaf/features/library/presentation/widgets/refresh_animation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:read_leaf/features/characters/presentation/widgets/character_info_popup.dart';
import 'package:read_leaf/core/constants/responsive_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:read_leaf/features/characters/data/category_constants.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:read_leaf/features/characters/data/public_character_repository.dart';
import 'package:read_leaf/generated/l10n.dart';

/// Controller class to manage character screen state
class CharacterScreenController {
  final AiCharacterService _characterService = getIt<AiCharacterService>();
  final ValueNotifier<AiCharacter?> selectedCharacter =
      ValueNotifier<AiCharacter?>(null);
  final ValueNotifier<List<AiCharacter>> characters =
      ValueNotifier<List<AiCharacter>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  StreamSubscription? _characterUpdateSubscription;

  CharacterScreenController() {
    // Initialize with the current selected character
    selectedCharacter.value = _characterService.getSelectedCharacter();

    // Listen for character updates from the service
    _characterUpdateSubscription =
        _characterService.onCharacterUpdate.listen((_) {
      selectedCharacter.value = _characterService.getSelectedCharacter();
    });

    // Initial load of characters
    loadCharacters();
  }

  void dispose() {
    selectedCharacter.dispose();
    characters.dispose();
    isLoading.dispose();
    _characterUpdateSubscription?.cancel();
  }

  Future<void> loadCharacters() async {
    isLoading.value = true;
    try {
      final allCharacters = await _characterService.getAllCharacters();
      characters.value = allCharacters;
    } catch (e) {
      debugPrint('Error loading characters: $e');
      // Fall back to sync method if async fails
      characters.value = _characterService.getCharactersSync();
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<AiCharacter>> getCharactersByCategory(String category) async {
    try {
      // For the Default category, only show default characters
      if (category == CharacterCategories.defaultCategory) {
        return characters.value
            .where((c) => c.tags.contains('Default'))
            .toList();
      }

      // For all other categories, exclude default characters
      List<AiCharacter> filteredCharacters;
      if (category == 'All') {
        filteredCharacters =
            characters.value.where((c) => !c.tags.contains('Default')).toList();
      } else {
        filteredCharacters =
            await _characterService.getCharactersByCategory(category);
        // Filter out default characters
        filteredCharacters = filteredCharacters
            .where((c) => !c.tags.contains('Default'))
            .toList();
      }

      return filteredCharacters;
    } catch (e) {
      // Fall back to filtering the current characters if the service call fails
      final filteredCharacters = characters.value
          .where((c) => category == 'All'
              ? !c.tags.contains('Default')
              : (c.tags.contains(category) && !c.tags.contains('Default')))
          .toList();
      return filteredCharacters;
    }
  }

  Future<List<AiCharacter>> getMostLikedCharacters({int limit = 5}) async {
    try {
      return await _characterService.getMostLikedCharacters(limit: limit);
    } catch (e) {
      debugPrint('Error getting most liked characters: $e');
      // Fall back to the current characters
      return characters.value.take(limit).toList();
    }
  }

  Future<void> selectCharacter(AiCharacter character,
      {VoidCallback? onCharacterChanged}) async {
    // Don't set state here - just call the service
    await _characterService.setSelectedCharacter(character);

    // The subscription will update the selectedCharacter ValueNotifier
    // Callback for any parent widgets
    onCharacterChanged?.call();
  }
}

class CharacterScreen extends StatefulWidget {
  final VoidCallback? onCharacterChanged;

  const CharacterScreen({
    super.key,
    this.onCharacterChanged,
  });

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CharacterScreenController _controller;
  bool _showVoices = false;
  final ScrollController _mainScrollController = ScrollController();
  final Map<String, ScrollController> _tabScrollControllers = {};
  bool _isScrollingDown = false;

  // Categories for characters
  final List<String> _categories = CharacterCategories.getAllCategories();

  // Default voices
  final List<Map<String, String>> _voices = [
    {
      'name': 'French',
      'description': 'The real French guy',
      'color': '#B71C1C',
      'tag': 'Default',
    },
    {
      'name': 'Bodyguard',
      'description': '👊 "My job is to protect you..." 👊 (Esp-Eng)',
      'color': '#827717',
      'tag': 'Default',
    },
    {
      'name': 'Francis',
      'description': '',
      'color': '#E91E63',
      'tag': 'Default',
    },
    {
      'name': 'Robot',
      'description': 'Just a robot :)',
      'color': '#FF9800',
      'tag': 'Default',
    },
    {
      'name': 'Tala',
      'description': 'Always up for an adventure',
      'color': '#FF9800',
      'tag': 'Default',
    },
    {
      'name': 'Southern',
      'description': 'Southern',
      'color': '#1B5E20',
      'tag': 'Default',
    },
    {
      'name': 'Taz',
      'description': 'Australian dude',
      'color': '#00695C',
      'tag': 'Default',
    },
    {
      'name': 'Bodhi',
      'description': 'A gentle breeze whispering through an ancient forest',
      'color': '#FF9800',
      'tag': 'Default',
    },
    {
      'name': 'Woman',
      'description': 'Girl Voice by Venn',
      'color': '#BF360C',
      'tag': 'Default',
    },
    {
      'name': 'Soft Bubbly',
      'description': 'Cheerful and sweet',
      'color': '#E91E63',
      'tag': 'Default',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = CharacterScreenController();
    _tabController = TabController(length: _categories.length, vsync: this);
    for (var category in _categories) {
      _tabScrollControllers[category] = ScrollController()
        ..addListener(() => _scrollListener(_tabScrollControllers[category]!));
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    for (var controller in _tabScrollControllers.values) {
      controller.dispose();
    }
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener(ScrollController controller) {
    if (!controller.hasClients) return;

    if (controller.position.userScrollDirection == ScrollDirection.reverse) {
      if (!_isScrollingDown) {
        _isScrollingDown = true;
        NavScreen.globalKey.currentState?.hideNavBar(true);
      }
    }

    if (controller.position.userScrollDirection == ScrollDirection.forward) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        NavScreen.globalKey.currentState?.hideNavBar(false);
      }
    }
  }

  void _selectCharacter(AiCharacter character) {
    if (!mounted) return;

    // First update the UI right away without waiting for the service
    // This makes the selection appear faster
    final currentContext = context;

    // Show a subtle visual feedback
    HapticFeedback.selectionClick();

    // Use a delayed navigator pop to make the transition smoother
    if (mounted && Navigator.canPop(context)) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && Navigator.canPop(currentContext)) {
          Navigator.pop(currentContext);
        }
      });
    }

    // Now update the actual selection in the background
    _controller.selectCharacter(character, onCharacterChanged: () {
      // Notify parent about character change
      widget.onCharacterChanged?.call();

      // Find and refresh HomeScreen
      if (mounted) {
        final homeScreen = context.findAncestorStateOfType<HomeScreenState>();
        homeScreen?.generateNewAIMessage();
      }
    });
  }

  // Create a method to handle refreshing after character create/import
  Future<void> _refreshAfterCharacterCreation() async {
    // Avoid a full rebuild by just updating the controller data
    await _controller.loadCharacters();

    // Notify parent
    widget.onCharacterChanged?.call();

    // Update home screen
    if (mounted) {
      final homeScreen = context.findAncestorStateOfType<HomeScreenState>();
      homeScreen?.generateNewAIMessage();
    }
  }

  void _toggleView() {
    setState(() {
      _showVoices = !_showVoices;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            if (!_showVoices) _buildTabBar(theme),
            Expanded(
              child: _showVoices
                  ? PullToRefreshAnimation(
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 2));
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: ListView.builder(
                        controller: _mainScrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: _voices.length,
                        itemBuilder: (context, index) {
                          final voice = _voices[index];
                          return _buildVoiceItem(voice, theme);
                        },
                      ),
                    )
                  : ValueListenableBuilder<bool>(
                      valueListenable: _controller.isLoading,
                      builder: (context, isLoading, child) {
                        if (isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return TabBarView(
                          controller: _tabController,
                          children: _categories.map((category) {
                            return PullToRefreshAnimation(
                              onRefresh: () async {
                                await _controller.loadCharacters();
                              },
                              child: SingleChildScrollView(
                                controller: _tabScrollControllers[category],
                                child: _buildCategoryContent(category, theme),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: !_showVoices
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Create button
                Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      splashColor: theme.primaryColor.withOpacity(0.1),
                      highlightColor: theme.primaryColor.withOpacity(0.05),
                      onTap: () async {
                        if (!mounted) return;

                        final RenderBox button =
                            context.findRenderObject() as RenderBox;
                        final Offset buttonPosition =
                            button.localToGlobal(Offset.zero);

                        final dialogResult = await showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (BuildContext dialogContext) {
                            return Stack(
                              children: [
                                Positioned(
                                  right: 16,
                                  bottom: buttonPosition.dy + 130,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(16)),
                                            splashColor: theme.primaryColor
                                                .withOpacity(0.1),
                                            highlightColor: theme.primaryColor
                                                .withOpacity(0.05),
                                            onTap: () async {
                                              Navigator.pop(dialogContext);
                                              if (!mounted) return;

                                              final result =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const CreateCharacterScreen()),
                                              );
                                              if (result == true && mounted) {
                                                widget.onCharacterChanged
                                                    ?.call();
                                                // Reload characters after creation
                                                await _refreshAfterCharacterCreation();
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.person_add,
                                                      color: theme.colorScheme
                                                          .onSurface),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Character',
                                                    style: TextStyle(
                                                      color: theme.colorScheme
                                                          .onSurface,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                              height: 1,
                                              color: theme.dividerColor),
                                          InkWell(
                                            splashColor: theme.primaryColor
                                                .withOpacity(0.1),
                                            highlightColor: theme.primaryColor
                                                .withOpacity(0.05),
                                            onTap: () async {
                                              Navigator.pop(dialogContext);
                                              if (!mounted) return;

                                              final result = await FilePicker
                                                  .platform
                                                  .pickFiles(
                                                type: FileType.custom,
                                                allowedExtensions: ['json'],
                                              );

                                              if (result != null && mounted) {
                                                final file = result.files.first;
                                                if (!mounted) return;

                                                final importResult =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ImportCharacterScreen(
                                                      filePath: file.path!,
                                                    ),
                                                  ),
                                                );

                                                if (importResult == true &&
                                                    mounted) {
                                                  // Reload characters after import
                                                  await _refreshAfterCharacterCreation();
                                                }
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.file_upload,
                                                      color: theme.colorScheme
                                                          .onSurface),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Import',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                              height: 1,
                                              color: theme.dividerColor),
                                          InkWell(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    bottom:
                                                        Radius.circular(16)),
                                            splashColor: theme.primaryColor
                                                .withOpacity(0.1),
                                            highlightColor: theme.primaryColor
                                                .withOpacity(0.05),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _toggleView();
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.record_voice_over,
                                                      color: theme.colorScheme
                                                          .onSurface),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Voice',
                                                    style: TextStyle(
                                                      color: theme.colorScheme
                                                          .onSurface,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: theme.colorScheme.onSurface),
                            const SizedBox(width: 8),
                            Text(
                              'Create',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showVoices
                    ? S.of(context).voices
                    : S.of(context).chooseCharacter,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton(theme),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // TODO: Implement search
                    },
                  ),
                ],
              ),
            ],
          ),
          if (_showVoices)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Recommended', true),
                    _buildFilterChip('Featured', false),
                    _buildFilterChip('Voices', false),
                    _buildFilterChip('Groups', false),
                    _buildFilterChip('Helper', false),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _toggleView,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _showVoices ? Icons.person : Icons.record_voice_over,
                size: 20,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                _showVoices ? S.of(context).characters : S.of(context).voice,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: null,
        backgroundColor: Colors.grey.withOpacity(0.1),
        selectedColor: Colors.blue.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: theme.colorScheme.onSurface,
        unselectedLabelColor:
            theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.primaryColor.withOpacity(0.1),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: _categories
            .map((category) => Tab(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CharacterCategories.getCategoryIcon(category),
                            size: 18),
                        const SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCategoryContent(String category, ThemeData theme) {
    return FutureBuilder<List<AiCharacter>>(
      future: _controller.getCharactersByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading characters: ${snapshot.error}',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          );
        }

        final characters = snapshot.data ?? [];

        if (characters.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context).noCharactersInCategory,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          child: ValueListenableBuilder<AiCharacter?>(
            valueListenable: _controller.selectedCharacter,
            builder: (context, selectedCharacter, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeaturedCharacters(theme, characters),
                  _buildTrendingCharacters(theme, characters),
                  _buildAllCharacters(theme, characters),
                  const SizedBox(height: 16),
                  _buildRecentCharacters(theme, category),
                  const SizedBox(height: 80),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVoiceItem(Map<String, String> voice, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor:
              Color(int.parse(voice['color']!.replaceAll('#', '0xFF'))),
          child: Text(
            voice['name']![0],
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          voice['name']!,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: voice['description']!.isNotEmpty
            ? Text(
                voice['description']!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildFeaturedCharacters(
      ThemeData theme, List<AiCharacter> characters) {
    // Find characters with the 'Community' tag for featured characters, excluding default characters
    List<AiCharacter> featuredCharacters = characters
        .where(
            (c) => c.tags.contains('Community') && !c.tags.contains('Default'))
        .take(5)
        .toList();

    // If we don't have 5 characters with the Community tag, fill with others (excluding defaults)
    if (featuredCharacters.length < 5) {
      final remainingCount = 5 - featuredCharacters.length;
      final otherCharacters = characters
          .where((c) =>
              !c.tags.contains('Community') &&
              !c.tags.contains('Default') &&
              !featuredCharacters.any((f) => f.name == c.name))
          .take(remainingCount)
          .toList();

      featuredCharacters.addAll(otherCharacters);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(S.of(context).featuredCharacters, theme),
        const SizedBox(height: 12),
        SizedBox(
          height: 180, // Increased height for the new card design
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: featuredCharacters.isEmpty
                ? Center(
                    key: const ValueKey('no-featured'),
                    child: Text(
                      S.of(context).noFeaturedCharacters,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  )
                : ListView.builder(
                    key: const ValueKey('featured-list'),
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: featuredCharacters.length,
                    itemBuilder: (context, index) =>
                        _buildFeaturedCharacterCard(
                      context,
                      featuredCharacters[index],
                      theme,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16), // Add spacing between sections
      ],
    );
  }

  Widget _buildFeaturedCharacterCard(
      BuildContext context, AiCharacter character, ThemeData theme) {
    final imageUrl = character.avatarImagePath ?? '';
    final description = character.summary ?? '';

    // More aggressive formatting to handle various types of line breaks and whitespace
    String formattedDescription = '';

    try {
      // Safe formatting: replace line breaks, normalize whitespace, and trim
      formattedDescription = description
          .replaceAll(RegExp(r'[\n\r]+'),
              ' ') // Replace any kind of line break with a space
          .replaceAll(RegExp(r'\s{2,}'),
              ' ') // Replace multiple spaces with a single space
          .trim();

      // Safely truncate with a reasonable length limit
      const maxLength = 120;
      if (formattedDescription.length > maxLength) {
        formattedDescription =
            '${formattedDescription.substring(0, maxLength)}...';
      }
    } catch (e) {
      // Fallback if any string processing fails
      debugPrint('Error formatting description: $e');
      formattedDescription = description.length > 120
          ? '${description.substring(0, 120)}...'
          : description;
    }

    return GestureDetector(
      onTap: () => _showCharacterInfoPopup(context, character),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 160,
        height: 180,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildAvatarImage(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.6, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Character name
                      Text(
                        character.name ?? S.of(context).unnamedCharacter,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Character description (truncated)
                      if (formattedDescription.isNotEmpty)
                        Text(
                          formattedDescription,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 2.0,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      // Like count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _toggleLike(character),
                            child: Icon(
                              character.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: character.isLiked
                                  ? Colors.redAccent
                                  : Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            character.likeCount.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllCharacters(ThemeData theme, List<AiCharacter> characters) {
    // State for expanded view
    final ValueNotifier<bool> expanded = ValueNotifier<bool>(false);

    final initialCount = 8; // Show only 8 characters initially
    final displayCount = expanded.value
        ? characters.length
        : initialCount.clamp(0, characters.length);

    return ValueListenableBuilder<bool>(
      valueListenable: expanded,
      builder: (context, isExpanded, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(S.of(context).allCharacters, theme),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: isExpanded
                  ? characters.length
                  : displayCount.clamp(0, characters.length),
              itemBuilder: (context, index) => _buildCharacterListCard(
                characters[index],
                theme,
              ),
            ),
            if (characters.length > initialCount) ...[
              const SizedBox(height: 12),
              _buildShowMoreButton(
                isExpanded: isExpanded,
                onPressed: () => expanded.value = !isExpanded,
                theme: theme,
                totalCount: characters.length,
                initialCount: initialCount,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildShowMoreButton({
    required bool isExpanded,
    required VoidCallback onPressed,
    required ThemeData theme,
    required int totalCount,
    required int initialCount,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(24),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.7),
                    theme.colorScheme.primaryContainer.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isExpanded
                          ? S.of(context).showLess
                          : S.of(context).showMore(totalCount - initialCount),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCharacters(ThemeData theme, String currentCategory) {
    // Get recently used characters from the service
    final allRecentCharacters =
        getIt<AiCharacterService>().getUserSelectedCharacters();

    // Filter by current category if not "All"
    List<AiCharacter> recentCharacters;
    if (currentCategory == 'All') {
      recentCharacters = allRecentCharacters.take(6).toList();
    } else {
      recentCharacters = allRecentCharacters
          .where((c) => c.tags.contains(currentCategory))
          .take(6)
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(S.of(context).recentCharacters, theme),
        const SizedBox(height: 12),
        recentCharacters.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    S.of(context).noRecentCharacters,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: recentCharacters.length,
                itemBuilder: (context, index) => _buildCharacterGridCard(
                  recentCharacters[index],
                  theme,
                ),
              ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            // Handle see all tap
          },
          child: Text(
            S.of(context).seeAll,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterListCard(
    AiCharacter character,
    ThemeData theme, {
    bool isSelected = false,
  }) {
    return ValueListenableBuilder<AiCharacter?>(
      valueListenable: _controller.selectedCharacter,
      builder: (context, selectedCharacter, child) {
        final isSelected = character.name == selectedCharacter?.name;
        final heroTag = 'list-${character.name}';

        // Process the summary to safely replace line breaks with spaces for better display
        String processedSummary = '';
        try {
          processedSummary = character.summary
              .replaceAll(RegExp(r'[\n\r]+'), ' ')
              .replaceAll(RegExp(r'\s{2,}'), ' ')
              .trim();
        } catch (e) {
          processedSummary = character.summary;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: theme.primaryColor, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () => _selectCharacter(character),
            onLongPress: () => _showCharacterInfoPopup(context, character),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: SizedBox(
                  width: 56,
                  height: 56,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: _buildAvatarImage(
                        character.avatarImagePath,
                        fit: BoxFit.cover,
                        memCacheWidth: 112,
                        memCacheHeight: 112,
                        heroTag: heroTag,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  character.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: Text(
                    processedSummary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: theme.primaryColor)
                    : const Icon(Icons.chevron_right),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCharacterGridCard(
    AiCharacter character,
    ThemeData theme, {
    bool isSelected = false,
  }) {
    return ValueListenableBuilder<AiCharacter?>(
      valueListenable: _controller.selectedCharacter,
      builder: (context, selectedCharacter, child) {
        final isSelected = character.name == selectedCharacter?.name;
        final heroTag = 'grid-${character.name}';

        // Format summary
        String processedSummary = '';
        try {
          processedSummary = character.summary
              .replaceAll(RegExp(r'[\n\r]+'), ' ')
              .replaceAll(RegExp(r'\s{2,}'), ' ')
              .trim();

          if (processedSummary.length > 60) {
            processedSummary = '${processedSummary.substring(0, 60)}...';
          }
        } catch (e) {
          processedSummary = character.summary;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: theme.primaryColor, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () => _selectCharacter(character),
            onLongPress: () => _showCharacterInfoPopup(context, character),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: _buildAvatarImage(
                      character.avatarImagePath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      memCacheWidth: 300,
                      memCacheHeight: 300,
                      heroTag: heroTag,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        processedSummary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.7),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to extract trait from character tags
  String _getCharacterTrait(AiCharacter character) {
    // If character has a single tag, use it as trait
    if (character.tags.isNotEmpty) {
      return character.tags.first;
    }

    // Otherwise use the first sentence/part of the summary
    final summary = character.summary;
    if (summary.contains('.')) {
      return summary.split('.').first.trim();
    }

    if (summary.contains('\n')) {
      return summary.split('\n').first.trim();
    }

    // Fallback to a portion of the summary
    if (summary.length > 30) {
      return '${summary.substring(0, 30).trim()}...';
    }

    return summary.isEmpty ? 'Character' : summary;
  }

  // Helper method to determine how to load the image based on the path
  Widget _buildAvatarImage(
    String imagePath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    bool useCircleAvatar = false,
    int? memCacheWidth,
    int? memCacheHeight,
    String? heroTag,
  }) {
    // Create a widget for the image
    Widget imageWidget;

    // Ensure we have valid cache dimensions (no Infinity or NaN)
    final safeCacheWidth = memCacheWidth ??
        ((width != null && width.isFinite && width > 0) ? width.toInt() : 200);
    final safeCacheHeight = memCacheHeight ??
        ((height != null && height.isFinite && height > 0)
            ? height.toInt()
            : 200);

    // Handle network URLs
    if (imagePath.startsWith('http') ||
        imagePath.startsWith('https') ||
        imagePath.contains('avatars.charhub.io')) {
      imageWidget = CachedNetworkImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) {
          debugPrint('Error loading avatar image: $url - $error');
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(
                Icons.person,
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        },
        memCacheHeight: safeCacheHeight,
        memCacheWidth: safeCacheWidth,
        fadeInDuration: const Duration(milliseconds: 200),
        httpHeaders: const {
          'Accept': 'image/png,image/jpeg,image/webp,image/*,*/*;q=0.8',
          'User-Agent': 'ReadLeaf/1.0',
          'Cache-Control': 'max-age=31536000',
        },
      );
    }

    // Handle asset images
    else if (imagePath.startsWith('assets/')) {
      imageWidget = Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading asset avatar image: $error');
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(
                Icons.person,
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        },
      );
    }

    // Handle local file paths
    else {
      try {
        imageWidget = Image.file(
          File(imagePath),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading file avatar image: $error');
            return Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          },
        );
      } catch (e) {
        debugPrint('Error creating file image: $e');
        // Fallback to a default avatar
        imageWidget = Image.asset(
          'assets/images/ai_characters/default_avatar.png',
          width: width,
          height: height,
          fit: fit,
        );
      }
    }

    // Wrap with Hero if heroTag is provided
    if (heroTag != null) {
      return Hero(
        tag: heroTag,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  void _showCharacterInfoPopup(BuildContext context, AiCharacter character) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => CharacterInfoPopup(
        character: character,
        onClose: () => Navigator.of(context).pop(),
        onSelect: () {
          Navigator.of(context).pop();
          _selectCharacter(character);
        },
      ),
    );
  }

  // Toggle character like status
  Future<void> _toggleLike(AiCharacter character) async {
    try {
      // Only allow liking community characters
      if (!character.tags.contains('Community')) return;

      // Show a visual feedback
      HapticFeedback.lightImpact();

      // For better user experience, update UI immediately instead of waiting for network
      setState(() {
        // Create a locally updated version of the character with toggled like state
        character = character.copyWith(
          isLiked: !character.isLiked,
          likeCount: character.isLiked
              ? character.likeCount - 1
              : character.likeCount + 1,
        );
      });

      // In the background, attempt to update on server
      // This won't block the UI or cause rebuilds
      try {
        final repo = getIt<PublicCharacterRepository>();
        final characterId = character.name; // Use name as ID for now

        if (character.isLiked) {
          await repo.unlikeCharacter(characterId);
        } else {
          await repo.likeCharacter(characterId);
        }
      } catch (e) {
        // Log server error but don't disrupt UI
        debugPrint('Server error toggling like: $e');
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      // Show a snackbar with the error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error liking character: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildTrendingCharacters(
      ThemeData theme, List<AiCharacter> characters) {
    // Get all characters and sort them by like count in descending order, excluding default characters
    final trendingCharacters = List<AiCharacter>.from(
        characters.where((c) => !c.tags.contains('Default')))
      ..sort((a, b) => b.likeCount.compareTo(a.likeCount));

    // Take the top 10
    final topCharacters = trendingCharacters.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(S.of(context).trending, theme),
        const SizedBox(height: 12),
        SizedBox(
          height: 180, // Same height as Featured
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: topCharacters.isEmpty
                ? Center(
                    key: const ValueKey('no-trending'),
                    child: Text(
                      S.of(context).noTrendingCharacters,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  )
                : ListView.builder(
                    key: const ValueKey('trending-list'),
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: topCharacters.length,
                    itemBuilder: (context, index) =>
                        _buildFeaturedCharacterCard(
                      context,
                      topCharacters[index],
                      theme,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16), // Add spacing between sections
      ],
    );
  }
}
