import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_leaf/widgets/snack_bar_widget.dart';
import 'package:read_leaf/features/search/presentation/blocs/search_bloc.dart';
import 'package:read_leaf/nav_screen.dart';
import 'package:read_leaf/core/constants/search_constants.dart';
import 'results_page.dart';
import 'package:read_leaf/injection/injection.dart';
import 'package:read_leaf/features/search/data/annas_archieve.dart';
import 'package:read_leaf/features/library/data/thumbnail_service.dart';
import 'package:read_leaf/core/constants/responsive_constants.dart';
import '../widgets/book_skeleton.dart';
import 'package:read_leaf/core/services/connectivity_service.dart';
import 'package:read_leaf/widgets/offline_state_widget.dart';
import 'package:read_leaf/core/utils/utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  String searchQuery = "";
  String selectedType = "All";
  String selectedSort = "Most Relevant";
  String selectedFileType = "All";
  late final SearchBloc _searchBloc;
  late final AnnasArchieve _annasArchieve;
  bool _isLoading = false;
  Map<String, List<BookData>>? _categoryBooks;
  final ScrollController _scrollController = ScrollController();
  bool _isScrollingDown = false;
  final Map<String, bool> _expandedSections = {};
  String _selectedCategory = 'Most Downloaded';
  late final ConnectivityService _connectivityService;

  // Add map to store category scroll positions
  final Map<String, GlobalKey> _categoryKeys = {};

  // Add estimated height for each category section
  final double _estimatedCategoryHeight =
      280; // Height of category header + content

  @override
  void initState() {
    super.initState();
    _searchBloc = getIt<SearchBloc>();
    _annasArchieve = getIt<AnnasArchieve>();
    _connectivityService = getIt<ConnectivityService>();

    print(
        'SearchScreen: Connectivity status: ${_connectivityService.status.value}');

    // Initialize category keys
    for (final category in SearchConstants.categoryQueries.keys) {
      _categoryKeys[category] = GlobalKey();
    }
    _fetchInitialData();
    _scrollController.addListener(_scrollListener);

    // Listen for connectivity changes
    _connectivityService.status.addListener(_handleConnectivityChange);

    // Force a connectivity check
    _connectivityService.checkConnectivity().then((status) {
      print('SearchScreen: Initial connectivity check: $status');
    });
  }

  void _handleConnectivityChange() {
    final status = _connectivityService.status.value;

    // If we came back online and have no data, try to fetch it
    if (status == NetworkStatus.online &&
        (_categoryBooks == null || _categoryBooks!.isEmpty)) {
      _fetchInitialData();
    }

    // Show a snackbar notification when connectivity changes
    if (mounted && context.mounted) {
      Utils.showConnectionSnackBar(context, status == NetworkStatus.online);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _connectivityService.status.removeListener(_handleConnectivityChange);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!_isScrollingDown) {
        _isScrollingDown = true;
        NavScreen.globalKey.currentState?.hideNavBar(true);
      }
    }
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        NavScreen.globalKey.currentState?.hideNavBar(false);
      }
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final Map<String, List<BookData>> categoryBooks = {};

      // Process each category sequentially to avoid rate limiting
      for (var entry in SearchConstants.categoryQueries.entries) {
        final category = entry.key;
        final queries = entry.value;

        // Create a set to store unique books based on title
        final Set<BookData> uniqueBooks = {};

        // Try each query until we have enough unique books
        for (var query in queries) {
          if (uniqueBooks.length >= 8) break;

          try {
            final results = await _annasArchieve.searchBooks(
              searchQuery: query,
              enableFilters: true,
              content: category == 'Top Fiction'
                  ? 'book_fiction'
                  : category == 'Top Non-Fiction'
                      ? 'book_nonfiction'
                      : '',
              sort: category == 'Most Downloaded' ? 'largest' : 'newest',
            );

            // Add only unique books
            for (var book in results) {
              if (uniqueBooks.length >= 8) break;
              // Check if book is unique based on title
              if (!uniqueBooks.any((b) => b.title == book.title)) {
                uniqueBooks.add(book);
              }
            }
          } catch (e) {
            print('Error fetching books for query $query: $e');
            continue;
          }
        }

        categoryBooks[category] = uniqueBooks.toList();
      }

      setState(() {
        _categoryBooks = categoryBooks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching initial data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _scrollToCategory(String category) {
    final categories = SearchConstants.categoryQueries.keys.toList();
    final index = categories.indexOf(category);
    if (index == -1) return;

    // Calculate approximate position
    final approximatePosition = index * _estimatedCategoryHeight;

    // First scroll to the approximate position
    _scrollController
        .animateTo(
      approximatePosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    )
        .then((_) {
      // After reaching approximate position, try to find exact position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final categoryKey = _categoryKeys[category];
        if (categoryKey?.currentContext != null) {
          Scrollable.ensureVisible(
            categoryKey!.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: 0.0,
          );
        }
      });
    });
  }

  void onSubmit(BuildContext context) {
    if (searchQuery.isNotEmpty) {
      _searchBloc.add(SearchBooks(
        query: searchQuery,
        content: SearchConstants.typeValues[selectedType] ?? '',
        sort: SearchConstants.sortValues[selectedSort] ?? '',
        fileType:
            selectedFileType == "All" ? '' : selectedFileType.toLowerCase(),
        enableFilters: true,
      ));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(searchQuery: searchQuery),
        ),
      );
    } else {
      showSnackBar(context: context, message: 'Search field is empty');
    }
  }

  void _showFilterModal(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavScreen.globalKey.currentState?.hideNavBar(true);
    });

    _expandedSections['Genre'] = true;

    showModalBottomSheet(
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.3,
              maxChildSize: 0.80,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color:
                                  isDark ? Colors.grey[700] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Filter",
                                style: theme.textTheme.displayMedium,
                              ),
                              const SizedBox(height: 8),
                              _buildExpandableSection(
                                "Genre",
                                expanded: true,
                                onExpansionChanged: (isExpanded) {
                                  setModalState(() {});
                                },
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: SearchConstants.typeValues.keys
                                      .map((String type) {
                                    return _buildFilterChip(
                                      type,
                                      selected: selectedType == type,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          selectedType = type;
                                        });
                                        setState(() {});
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildExpandableSection(
                                "Format",
                                expanded: false,
                                onExpansionChanged: (isExpanded) {
                                  setModalState(() {});
                                },
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: SearchConstants.fileTypes
                                      .map((String format) {
                                    return _buildFilterChip(
                                      format,
                                      selected: selectedFileType == format,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          selectedFileType = format;
                                        });
                                        setState(() {});
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildExpandableSection(
                                "Sort by",
                                expanded: false,
                                onExpansionChanged: (isExpanded) {
                                  setModalState(() {});
                                },
                                child: Column(
                                  children: SearchConstants.sortValues.keys
                                      .map((String sort) {
                                    return _buildRadioTile(
                                      sort,
                                      selectedSort == sort,
                                      onChanged: (selected) {
                                        if (selected) {
                                          setModalState(() {
                                            selectedSort = sort;
                                          });
                                          setState(() {});
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      NavScreen.globalKey.currentState?.hideNavBar(false);
    });
  }

  Widget _buildExpandableSection(
    String title, {
    required bool expanded,
    required Widget child,
    Function(bool)? onExpansionChanged,
  }) {
    final theme = Theme.of(context);
    _expandedSections[title] ??= expanded;

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey(title),
        title: Text(
          title,
          style: theme.textTheme.titleLarge,
        ),
        trailing: Icon(
          _expandedSections[title] == true ? Icons.remove : Icons.add,
          color: theme.primaryColor,
        ),
        initiallyExpanded: _expandedSections[title] ?? expanded,
        onExpansionChanged: (isExpanded) {
          setState(() {
            _expandedSections[title] = isExpanded;
          });
          onExpansionChanged?.call(isExpanded);
        },
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label, {
    required bool selected,
    required Function(bool) onSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: theme.primaryColor.withOpacity(0.2),
      backgroundColor: theme.cardColor,
      labelStyle: TextStyle(
        color: selected
            ? theme.primaryColor
            : (isDark ? Colors.white : Colors.black87),
      ),
      checkmarkColor: theme.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side:
            selected ? BorderSide(color: theme.primaryColor) : BorderSide.none,
      ),
    );
  }

  Widget _buildRadioTile(
    String title,
    bool isSelected, {
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      leading: Radio<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (value) => onChanged(value ?? false),
        activeColor: theme.primaryColor,
      ),
      onTap: () => onChanged(!isSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = ResponsiveConstants.isTablet(context);

    return BlocConsumer<SearchBloc, SearchState>(
      bloc: _searchBloc,
      listener: (context, state) {
        if (state is SearchError) {
          showSnackBar(context: context, message: state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                backgroundColor: theme.scaffoldBackgroundColor,
                title: Text(
                  'Search',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: theme.iconTheme.color,
                      size: 20,
                    ),
                    onPressed: () => _showFilterModal(context),
                  ),
                  const SizedBox(width: 8),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(isTablet ? 120 : 100),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            onTap: () => NavScreen.globalKey.currentState
                                ?.hideNavBar(true),
                            onTapOutside: (value) {
                              NavScreen.globalKey.currentState
                                  ?.hideNavBar(false);
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.search,
                                color: theme.iconTheme.color?.withOpacity(0.5),
                                size: 20,
                              ),
                              hintText: "Find some books...",
                              hintStyle: TextStyle(
                                color: theme.iconTheme.color?.withOpacity(0.5),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            onSubmitted: (_) => onSubmit(context),
                            onChanged: (value) =>
                                setState(() => searchQuery = value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 32,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: SearchConstants.categoryQueries.length,
                          itemBuilder: (context, index) {
                            final category = SearchConstants
                                .categoryQueries.keys
                                .elementAt(index);
                            final isSelected = category == _selectedCategory;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() => _selectedCategory = category);
                                  _scrollToCategory(category);
                                },
                                backgroundColor: theme.cardColor,
                                selectedColor:
                                    theme.colorScheme.primary.withOpacity(0.2),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => CategorySkeleton(isTablet: isTablet),
                    childCount: 3,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (_categoryBooks == null) return const SizedBox();
                      final category =
                          SearchConstants.categoryQueries.keys.elementAt(index);
                      final books = _categoryBooks![category] ?? [];
                      if (books.isEmpty) return const SizedBox();

                      return _buildBookCategory(
                        title: category,
                        books: books,
                        isTablet: isTablet,
                      );
                    },
                    childCount: SearchConstants.categoryQueries.length,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookCategory({
    required String title,
    required List<BookData> books,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      key: _categoryKeys[title],
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 10,
            vertical: isTablet ? 24 : 20,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: isTablet ? 220 : 180,
          child: ListView.builder(
            key: PageStorageKey(title),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 10),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return RepaintBoundary(
                child: Padding(
                  padding: EdgeInsets.only(right: isTablet ? 16 : 10),
                  child: GestureDetector(
                    onTap: () {
                      _searchBloc.add(SearchBooks(
                        query: book.title ?? "",
                        enableFilters: false,
                      ));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ResultPage(searchQuery: book.title ?? ""),
                        ),
                      );
                    },
                    child: Container(
                      width: isTablet ? 150 : 120,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black26 : Colors.black12,
                            blurRadius: isTablet ? 6 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (book.thumbnail != null)
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(isTablet ? 12 : 8),
                              ),
                              child: SizedBox(
                                height: isTablet ? 150 : 120,
                                width: isTablet ? 150 : 120,
                                child: FutureBuilder<ImageProvider>(
                                  key: ValueKey(book.thumbnail),
                                  future: ThumbnailService()
                                      .getNetworkThumbnail(book.thumbnail!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: isTablet ? 3 : 2,
                                          color: theme.primaryColor,
                                        ),
                                      );
                                    }
                                    if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Container(
                                        color: isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[300],
                                        child: Icon(
                                          Icons.book,
                                          size: isTablet ? 48 : 40,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                        ),
                                      );
                                    }
                                    return Image(
                                      key: ValueKey(book.thumbnail),
                                      image: snapshot.data!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: isDark
                                              ? Colors.grey[800]
                                              : Colors.grey[300],
                                          child: Icon(
                                            Icons.book,
                                            size: isTablet ? 48 : 40,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black54,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            )
                          else
                            Container(
                              height: isTablet ? 150 : 120,
                              color:
                                  isDark ? Colors.grey[800] : Colors.grey[300],
                              child: Icon(
                                Icons.book,
                                size: isTablet ? 48 : 40,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.all(isTablet ? 12 : 8),
                            child: Text(
                              book.title ?? "Unknown",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
