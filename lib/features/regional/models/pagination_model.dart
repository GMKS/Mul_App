/// Pagination Models for Cursor-based Pagination
/// Implements cursor-based pagination to avoid duplicate videos

/// Pagination cursor for tracking position
class PaginationCursor {
  final String? cursor;
  final int pageSize;
  final bool hasMore;

  const PaginationCursor({
    this.cursor,
    this.pageSize = 10,
    this.hasMore = true,
  });

  /// Initial cursor for first page
  factory PaginationCursor.initial({int pageSize = 10}) {
    return PaginationCursor(
      cursor: null,
      pageSize: pageSize,
      hasMore: true,
    );
  }

  /// Create next cursor from last item
  PaginationCursor nextCursor(String? lastItemId, bool hasMoreItems) {
    return PaginationCursor(
      cursor: lastItemId,
      pageSize: pageSize,
      hasMore: hasMoreItems,
    );
  }

  /// Reset cursor to initial state
  PaginationCursor reset() {
    return PaginationCursor(
      cursor: null,
      pageSize: pageSize,
      hasMore: true,
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      if (cursor != null) 'cursor': cursor,
      'limit': pageSize,
    };
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;
  final int totalCount;

  const PaginatedResponse({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.totalCount = 0,
  });

  /// Create empty response
  factory PaginatedResponse.empty() {
    return const PaginatedResponse(
      items: [],
      nextCursor: null,
      hasMore: false,
      totalCount: 0,
    );
  }

  /// Check if response has data
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

/// Feed loading state
enum FeedLoadingState {
  initial,
  loading,
  loadingMore,
  loaded,
  error,
  empty,
}

/// Feed state container
class FeedState<T> {
  final List<T> items;
  final FeedLoadingState loadingState;
  final String? errorMessage;
  final PaginationCursor cursor;
  final Set<String> loadedIds;

  const FeedState({
    this.items = const [],
    this.loadingState = FeedLoadingState.initial,
    this.errorMessage,
    required this.cursor,
    this.loadedIds = const {},
  });

  /// Initial state
  factory FeedState.initial({int pageSize = 10}) {
    return FeedState(
      items: [],
      loadingState: FeedLoadingState.initial,
      cursor: PaginationCursor.initial(pageSize: pageSize),
      loadedIds: {},
    );
  }

  /// Check states
  bool get isLoading => loadingState == FeedLoadingState.loading;
  bool get isLoadingMore => loadingState == FeedLoadingState.loadingMore;
  bool get isLoaded => loadingState == FeedLoadingState.loaded;
  bool get hasError => loadingState == FeedLoadingState.error;
  bool get isEmpty => loadingState == FeedLoadingState.empty;
  bool get canLoadMore => cursor.hasMore && !isLoading && !isLoadingMore;

  /// Copy with modifications
  FeedState<T> copyWith({
    List<T>? items,
    FeedLoadingState? loadingState,
    String? errorMessage,
    PaginationCursor? cursor,
    Set<String>? loadedIds,
  }) {
    return FeedState(
      items: items ?? this.items,
      loadingState: loadingState ?? this.loadingState,
      errorMessage: errorMessage ?? this.errorMessage,
      cursor: cursor ?? this.cursor,
      loadedIds: loadedIds ?? this.loadedIds,
    );
  }

  /// Start loading
  FeedState<T> startLoading() {
    return copyWith(
      loadingState: items.isEmpty
          ? FeedLoadingState.loading
          : FeedLoadingState.loadingMore,
    );
  }

  /// Add items (with deduplication)
  FeedState<T> addItems(
    List<T> newItems,
    String Function(T) getId,
    String? nextCursor,
    bool hasMore,
  ) {
    final newLoadedIds = Set<String>.from(loadedIds);
    final uniqueItems = <T>[];

    for (final item in newItems) {
      final id = getId(item);
      if (!newLoadedIds.contains(id)) {
        newLoadedIds.add(id);
        uniqueItems.add(item);
      }
    }

    final allItems = [...items, ...uniqueItems];

    return FeedState(
      items: allItems,
      loadingState:
          allItems.isEmpty ? FeedLoadingState.empty : FeedLoadingState.loaded,
      cursor: cursor.nextCursor(nextCursor, hasMore),
      loadedIds: newLoadedIds,
    );
  }

  /// Replace all items (for refresh)
  FeedState<T> replaceItems(
    List<T> newItems,
    String Function(T) getId,
    String? nextCursor,
    bool hasMore,
  ) {
    final newLoadedIds = <String>{};

    for (final item in newItems) {
      newLoadedIds.add(getId(item));
    }

    return FeedState(
      items: newItems,
      loadingState:
          newItems.isEmpty ? FeedLoadingState.empty : FeedLoadingState.loaded,
      cursor: PaginationCursor(
        cursor: nextCursor,
        pageSize: cursor.pageSize,
        hasMore: hasMore,
      ),
      loadedIds: newLoadedIds,
    );
  }

  /// Set error
  FeedState<T> setError(String message) {
    return copyWith(
      loadingState: FeedLoadingState.error,
      errorMessage: message,
    );
  }

  /// Reset state
  FeedState<T> reset() {
    return FeedState.initial(pageSize: cursor.pageSize);
  }
}
