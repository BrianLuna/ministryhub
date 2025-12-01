import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

// Sentinel value for copyWith to distinguish between null and not provided
const _undefined = Object();

/// Provider for church repository
final churchRepositoryProvider = Provider<ChurchRepository>((ref) {
  final firestoreDatasource = ChurchFirestoreDatasource();
  return ChurchRepositoryImpl(firestoreDatasource: firestoreDatasource);
});

/// Provider for use cases
final createChurchUseCaseProvider = Provider<CreateChurchUseCase>((ref) {
  final churchRepository = ref.watch(churchRepositoryProvider);
  final ministryRepository = ref.watch(ministryRepositoryProvider);
  return CreateChurchUseCase(churchRepository, ministryRepository);
});

final getChurchesByUserUseCaseProvider = Provider<GetChurchesByUserUseCase>((
  ref,
) {
  final repository = ref.watch(churchRepositoryProvider);
  return GetChurchesByUserUseCase(repository);
});

final getChurchesByMinistryUseCaseProvider =
    Provider<GetChurchesByMinistryUseCase>((ref) {
      final repository = ref.watch(churchRepositoryProvider);
      return GetChurchesByMinistryUseCase(repository);
    });

final updateChurchUseCaseProvider = Provider<UpdateChurchUseCase>((ref) {
  final repository = ref.watch(churchRepositoryProvider);
  return UpdateChurchUseCase(repository);
});

final deleteChurchUseCaseProvider = Provider<DeleteChurchUseCase>((ref) {
  final repository = ref.watch(churchRepositoryProvider);
  return DeleteChurchUseCase(repository);
});

final watchChurchUseCaseProvider = Provider<WatchChurchUseCase>((ref) {
  final repository = ref.watch(churchRepositoryProvider);
  return WatchChurchUseCase(repository);
});

final watchChurchesByUserUseCaseProvider = Provider<WatchChurchesByUserUseCase>(
  (ref) {
    final repository = ref.watch(churchRepositoryProvider);
    return WatchChurchesByUserUseCase(repository);
  },
);

final watchChurchesByMinistryUseCaseProvider =
    Provider<WatchChurchesByMinistryUseCase>((ref) {
      final repository = ref.watch(churchRepositoryProvider);
      return WatchChurchesByMinistryUseCase(repository);
    });

final getChurchesCountByMinistryUseCaseProvider =
    Provider<GetChurchesCountByMinistryUseCase>((ref) {
      final repository = ref.watch(churchRepositoryProvider);
      return GetChurchesCountByMinistryUseCase(repository);
    });

final reassignChurchesToMinistryUseCaseProvider =
    Provider<ReassignChurchesToMinistryUseCase>((ref) {
      final repository = ref.watch(churchRepositoryProvider);
      return ReassignChurchesToMinistryUseCase(repository);
    });

/// Controller for church operations
class ChurchController extends StateNotifier<ChurchState> {
  ChurchController({
    required CreateChurchUseCase createChurchUseCase,
    required GetChurchesByUserUseCase getChurchesByUserUseCase,
    required UpdateChurchUseCase updateChurchUseCase,
    required DeleteChurchUseCase deleteChurchUseCase,
    required WatchChurchUseCase watchChurchUseCase,
    required WatchChurchesByUserUseCase watchChurchesByUserUseCase,
    required ChurchRepository repository,
    String? userId,
  }) : _createChurchUseCase = createChurchUseCase,
       _getChurchesByUserUseCase = getChurchesByUserUseCase,
       _updateChurchUseCase = updateChurchUseCase,
       _deleteChurchUseCase = deleteChurchUseCase,
       _watchChurchUseCase = watchChurchUseCase,
       _watchChurchesByUserUseCase = watchChurchesByUserUseCase,
       super(const ChurchState.initial()) {
    if (userId != null) {
      loadChurches(userId);
    }
  }

  final CreateChurchUseCase _createChurchUseCase;
  final GetChurchesByUserUseCase _getChurchesByUserUseCase;
  final UpdateChurchUseCase _updateChurchUseCase;
  final DeleteChurchUseCase _deleteChurchUseCase;
  final WatchChurchUseCase _watchChurchUseCase;
  final WatchChurchesByUserUseCase _watchChurchesByUserUseCase;
  StreamSubscription<Church?>? _churchSubscription;
  StreamSubscription<List<Church>>? _churchesListSubscription;
  bool _isDisposed = false;

  /// Load churches for the current user
  Future<void> loadChurches(String userId) async {
    debugPrint('ChurchController: Loading churches for $userId...');
    if (_isDisposed) return;
    if (!_isDisposed) {
      state = state.copyWith(isLoading: true);
    }
    try {
      final churches = await _getChurchesByUserUseCase(
        userId,
      ).timeout(const Duration(seconds: 5));
      debugPrint('ChurchController: Loaded ${churches.length} churches.');
      if (_isDisposed) return;

      if (!_isDisposed) {
        state = state.copyWith(
          churches: churches,
          isLoading: false,
          error: null,
        );
      }

      // Start watching for real-time updates
      _watchChurchesList(userId);
    } catch (e, stack) {
      debugPrint('ChurchController: Error loading churches: $e\n$stack');
      if (!_isDisposed) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load churches: ${e.toString()}',
        );
      }
    }
  }

  /// Watch churches list for real-time updates
  void _watchChurchesList(String userId) {
    if (_isDisposed) return;

    _churchesListSubscription?.cancel();
    _churchesListSubscription = _watchChurchesByUserUseCase(userId).listen(
      (churches) {
        if (_isDisposed) return;

        // Update selected church if it still exists
        Church? updatedSelected;
        if (state.selectedChurch != null) {
          try {
            updatedSelected = churches.firstWhere(
              (c) => c.id == state.selectedChurch!.id,
            );
          } catch (e) {
            // Selected church no longer exists
            updatedSelected = null;
          }
        }

        state = state.copyWith(
          churches: churches,
          selectedChurch: updatedSelected,
        );
      },
      onError: (error) {
        if (_isDisposed) return;
        state = state.copyWith(
          error: 'Failed to watch churches list: ${error.toString()}',
        );
      },
    );
  }

  /// Create a new church
  Future<Church?> createChurch({
    required String name,
    required Location location,
    required String ministryId,
  }) async {
    if (_isDisposed) return null;
    if (!_isDisposed) {
      state = state.copyWith(isCreating: true, error: null);
    }
    try {
      final church = await _createChurchUseCase(
        name: name,
        location: location,
        ministryId: ministryId,
      );
      if (_isDisposed) return null;

      if (!_isDisposed) {
        state = state.copyWith(selectedChurch: church, isCreating: false);
      }

      return church;
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isCreating: false,
          error: 'Failed to create church: ${e.toString()}',
        );
      }
      return null;
    }
  }

  /// Select a church
  void selectChurch(Church? church) {
    // Cancel previous subscription
    _churchSubscription?.cancel();
    _churchSubscription = null;

    state = state.copyWith(selectedChurch: church);

    // Start listening to church changes
    if (church != null) {
      _watchSelectedChurch(church.ministryId, church.id);
    }
  }

  /// Watch selected church for real-time updates
  void _watchSelectedChurch(String ministryId, String churchId) {
    if (_isDisposed) return;

    _churchSubscription?.cancel();
    _churchSubscription = _watchChurchUseCase(ministryId, churchId).listen(
      (church) {
        if (_isDisposed) return;
        state = state.copyWith(selectedChurch: church);
      },
      onError: (error) {
        if (_isDisposed) return;
        state = state.copyWith(
          error: 'Failed to watch church: ${error.toString()}',
        );
      },
    );
  }

  /// Update church
  Future<bool> updateChurch({
    required String ministryId,
    required String churchId,
    String? name,
    Location? location,
    String? newMinistryId,
  }) async {
    if (_isDisposed) return false;
    if (!_isDisposed) {
      state = state.copyWith(isSaving: true, error: null);
    }
    try {
      await _updateChurchUseCase(
        ministryId: ministryId,
        churchId: churchId,
        name: name,
        location: location,
        newMinistryId: newMinistryId,
      );
      if (_isDisposed) return false;

      if (!_isDisposed) {
        state = state.copyWith(isSaving: false);
      }

      return true;
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isSaving: false,
          error: 'Failed to update church: ${e.toString()}',
        );
      }
      return false;
    }
  }

  /// Delete church
  Future<bool> deleteChurch(String ministryId, String churchId) async {
    if (_isDisposed) return false;
    if (!_isDisposed) {
      state = state.copyWith(isDeleting: true, error: null);
    }
    try {
      await _deleteChurchUseCase(ministryId, churchId);
      if (_isDisposed) return false;

      // Clear selection if deleted church was selected
      if (state.selectedChurch?.id == churchId) {
        if (!_isDisposed) {
          state = state.copyWith(selectedChurch: null);
        }
      }

      if (!_isDisposed) {
        state = state.copyWith(isDeleting: false);
      }

      return true;
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isDeleting: false,
          error: 'Failed to delete church: ${e.toString()}',
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _churchSubscription?.cancel();
    _churchSubscription = null;
    _churchesListSubscription?.cancel();
    _churchesListSubscription = null;
    super.dispose();
  }
}

/// State for church operations
class ChurchState {
  const ChurchState({
    required this.isLoading,
    required this.isCreating,
    required this.isSaving,
    required this.isDeleting,
    this.churches = const [],
    this.selectedChurch,
    this.error,
  });

  const ChurchState.initial()
    : isLoading = false,
      isCreating = false,
      isSaving = false,
      isDeleting = false,
      churches = const [],
      selectedChurch = null,
      error = null;

  final bool isLoading;
  final bool isCreating;
  final bool isSaving;
  final bool isDeleting;
  final List<Church> churches;
  final Church? selectedChurch;
  final String? error;

  ChurchState copyWith({
    bool? isLoading,
    bool? isCreating,
    bool? isSaving,
    bool? isDeleting,
    List<Church>? churches,
    Church? selectedChurch,
    Object? error = _undefined,
  }) {
    return ChurchState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      churches: churches ?? this.churches,
      selectedChurch: selectedChurch ?? this.selectedChurch,
      error: error == _undefined ? this.error : error as String?,
    );
  }
}

/// Provider for church controller
final churchControllerProvider =
    StateNotifierProvider<ChurchController, ChurchState>((ref) {
      final authState = ref.watch(authControllerProvider);
      final userId = authState.user?.uid;

      return ChurchController(
        createChurchUseCase: ref.watch(createChurchUseCaseProvider),
        getChurchesByUserUseCase: ref.watch(getChurchesByUserUseCaseProvider),
        updateChurchUseCase: ref.watch(updateChurchUseCaseProvider),
        deleteChurchUseCase: ref.watch(deleteChurchUseCaseProvider),
        watchChurchUseCase: ref.watch(watchChurchUseCaseProvider),
        watchChurchesByUserUseCase: ref.watch(
          watchChurchesByUserUseCaseProvider,
        ),
        repository: ref.watch(churchRepositoryProvider),
        userId: userId,
      );
    });
