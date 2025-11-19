import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ministryhub/ministryhub.dart';

/// Provider for ministry repository
final ministryRepositoryProvider = Provider<MinistryRepository>((ref) {
  final firestoreDatasource = MinistryFirestoreDatasource();
  final storageDatasource = MinistryStorageDatasource();
  return MinistryRepositoryImpl(
    firestoreDatasource: firestoreDatasource,
    storageDatasource: storageDatasource,
  );
});

/// Provider for use cases
final createMinistryUseCaseProvider = Provider<CreateMinistryUseCase>((ref) {
  final repository = ref.watch(ministryRepositoryProvider);
  return CreateMinistryUseCase(repository);
});

final getMinistriesByUserUseCaseProvider = Provider<GetMinistriesByUserUseCase>(
  (ref) {
    final repository = ref.watch(ministryRepositoryProvider);
    return GetMinistriesByUserUseCase(repository);
  },
);

final getMinistriesByAdministratorUseCaseProvider =
    Provider<GetMinistriesByAdministratorUseCase>((ref) {
      final repository = ref.watch(ministryRepositoryProvider);
      return GetMinistriesByAdministratorUseCase(repository);
    });

final updateMinistryUseCaseProvider = Provider<UpdateMinistryUseCase>((ref) {
  final repository = ref.watch(ministryRepositoryProvider);
  return UpdateMinistryUseCase(repository);
});

final uploadMinistryLogoUseCaseProvider = Provider<UploadMinistryLogoUseCase>((
  ref,
) {
  final repository = ref.watch(ministryRepositoryProvider);
  return UploadMinistryLogoUseCase(repository);
});

final checkUserIsAdministratorUseCaseProvider =
    Provider<CheckUserIsAdministratorUseCase>((ref) {
      final repository = ref.watch(ministryRepositoryProvider);
      return CheckUserIsAdministratorUseCase(repository);
    });

final deleteMinistryUseCaseProvider = Provider<DeleteMinistryUseCase>((ref) {
  final repository = ref.watch(ministryRepositoryProvider);
  return DeleteMinistryUseCase(repository);
});

final watchMinistryUseCaseProvider = Provider<WatchMinistryUseCase>((ref) {
  final repository = ref.watch(ministryRepositoryProvider);
  return WatchMinistryUseCase(repository);
});

final watchMinistriesByUserUseCaseProvider =
    Provider<WatchMinistriesByUserUseCase>((ref) {
      final repository = ref.watch(ministryRepositoryProvider);
      return WatchMinistriesByUserUseCase(repository);
    });

/// Controller for ministry operations
class MinistryController extends StateNotifier<MinistryState> {
  MinistryController({
    required CreateMinistryUseCase createMinistryUseCase,
    required GetMinistriesByUserUseCase getMinistriesByUserUseCase,
    required UpdateMinistryUseCase updateMinistryUseCase,
    required UploadMinistryLogoUseCase uploadMinistryLogoUseCase,
    required DeleteMinistryUseCase deleteMinistryUseCase,
    required WatchMinistryUseCase watchMinistryUseCase,
    required WatchMinistriesByUserUseCase watchMinistriesByUserUseCase,
    required ImagePicker imagePicker,
    required PreferencesService preferencesService,
    String? userId,
  }) : _createMinistryUseCase = createMinistryUseCase,
       _getMinistriesByUserUseCase = getMinistriesByUserUseCase,
       _updateMinistryUseCase = updateMinistryUseCase,
       _uploadMinistryLogoUseCase = uploadMinistryLogoUseCase,
       _deleteMinistryUseCase = deleteMinistryUseCase,
       _watchMinistryUseCase = watchMinistryUseCase,
       _watchMinistriesByUserUseCase = watchMinistriesByUserUseCase,
       _imagePicker = imagePicker,
       _preferencesService = preferencesService,
       _userId = userId,
       super(const MinistryState.initial()) {
    if (userId != null) {
      _loadPreferredMinistry(userId);
      loadMinistries(userId);
    }
  }

  final CreateMinistryUseCase _createMinistryUseCase;
  final GetMinistriesByUserUseCase _getMinistriesByUserUseCase;
  final UpdateMinistryUseCase _updateMinistryUseCase;
  final UploadMinistryLogoUseCase _uploadMinistryLogoUseCase;
  final DeleteMinistryUseCase _deleteMinistryUseCase;
  final WatchMinistryUseCase _watchMinistryUseCase;
  final WatchMinistriesByUserUseCase _watchMinistriesByUserUseCase;
  final ImagePicker _imagePicker;
  final PreferencesService _preferencesService;
  String? _userId;
  StreamSubscription<Ministry?>? _ministrySubscription;
  StreamSubscription<List<Ministry>>? _ministriesListSubscription;

  /// Load ministries for the current user
  Future<void> loadMinistries(String userId) async {
    _userId = userId;
    state = state.copyWith(isLoading: true);
    try {
      final ministries = await _getMinistriesByUserUseCase(userId);

      // Load preferred ministry if not already set
      if (state.selectedMinistry == null) {
        await _loadPreferredMinistry(userId);
      }

      // If preferred ministry is set, try to select it
      if (state.preferredMinistryId != null && ministries.isNotEmpty) {
        final preferred = ministries.firstWhere(
          (m) => m.id == state.preferredMinistryId,
          orElse: () => ministries.first,
        );
        state = state.copyWith(
          ministries: ministries,
          selectedMinistry: preferred,
          isLoading: false,
        );
        // Start watching the selected ministry
        _watchSelectedMinistry(preferred.id);
      } else if (ministries.isNotEmpty) {
        // Select first ministry if no preference
        state = state.copyWith(
          ministries: ministries,
          selectedMinistry: ministries.first,
          isLoading: false,
        );
        // Start watching the selected ministry
        _watchSelectedMinistry(ministries.first.id);
      } else {
        state = state.copyWith(
          ministries: ministries,
          selectedMinistry: null,
          isLoading: false,
        );
      }

      // Start watching the ministries list for real-time updates
      _watchMinistriesList(userId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Watch ministries list for real-time updates
  void _watchMinistriesList(String userId) {
    _ministriesListSubscription?.cancel();
    _ministriesListSubscription = _watchMinistriesByUserUseCase(userId).listen(
      (updatedMinistries) {
        // Update the ministries list
        // If selected ministry still exists, update it; otherwise select first
        Ministry? updatedSelected = state.selectedMinistry;
        if (state.selectedMinistry != null) {
          final found = updatedMinistries.firstWhere(
            (m) => m.id == state.selectedMinistry!.id,
            orElse: () => updatedMinistries.isNotEmpty
                ? updatedMinistries.first
                : state.selectedMinistry!,
          );
          if (found.id != state.selectedMinistry!.id) {
            // Selected ministry was removed, select first or null
            updatedSelected = updatedMinistries.isNotEmpty
                ? updatedMinistries.first
                : null;
            // Update watching subscription if needed
            if (updatedSelected != null) {
              _watchSelectedMinistry(updatedSelected.id);
            } else {
              _ministrySubscription?.cancel();
              _ministrySubscription = null;
            }
          } else {
            // Selected ministry still exists, update it
            updatedSelected = found;
          }
        } else if (updatedMinistries.isNotEmpty) {
          // No selected ministry, select first
          updatedSelected = updatedMinistries.first;
          _watchSelectedMinistry(updatedSelected.id);
        }

        state = state.copyWith(
          ministries: updatedMinistries,
          selectedMinistry: updatedSelected,
        );
      },
      onError: (error) {
        state = state.copyWith(
          error: 'Failed to watch ministries list: ${error.toString()}',
        );
      },
    );
  }

  /// Load preferred ministry from preferences
  Future<void> _loadPreferredMinistry(String userId) async {
    try {
      final preferredId = await _preferencesService.getStringForUser(
        'preferredMinistryId',
        userId,
      );
      if (preferredId != null && preferredId.isNotEmpty) {
        state = state.copyWith(preferredMinistryId: preferredId);
      }
    } catch (e) {
      // Ignore errors loading preference
    }
  }

  /// Set preferred ministry
  Future<void> setPreferredMinistry(String? ministryId, String userId) async {
    try {
      if (ministryId != null) {
        await _preferencesService.setStringForUser(
          'preferredMinistryId',
          userId,
          ministryId,
        );
      } else {
        // Remove preference
        final userKey = 'preferredMinistryId_$userId';
        await _preferencesService.prefs?.remove(userKey);
      }
      state = state.copyWith(preferredMinistryId: ministryId);
    } catch (e) {
      // Ignore errors saving preference
    }
  }

  /// Get preferred ministry ID
  String? getPreferredMinistryId() {
    return state.preferredMinistryId;
  }

  /// Create a new ministry
  Future<Ministry?> createMinistry({
    required String name,
    required String administratorId,
  }) async {
    state = state.copyWith(isCreating: true, error: null);
    try {
      final ministry = await _createMinistryUseCase(
        name: name,
        administratorId: administratorId,
      );

      // Add to ministries list
      final updatedMinistries = [...state.ministries, ministry];

      // Select the new ministry
      state = state.copyWith(
        ministries: updatedMinistries,
        selectedMinistry: ministry,
        isCreating: false,
      );

      // Start watching the new ministry
      _watchSelectedMinistry(ministry.id);

      // If this is the first ministry, set it as preferred
      if (updatedMinistries.length == 1 && _userId != null) {
        await setPreferredMinistry(ministry.id, _userId!);
      }

      return ministry;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Failed to create ministry: ${e.toString()}',
      );
      return null;
    }
  }

  /// Select a ministry
  void selectMinistry(Ministry? ministry) {
    // Cancel previous subscription
    _ministrySubscription?.cancel();
    _ministrySubscription = null;

    state = state.copyWith(selectedMinistry: ministry);

    // Save as preferred if user is set
    if (ministry != null && _userId != null) {
      setPreferredMinistry(ministry.id, _userId!);
      // Start listening to ministry changes
      _watchSelectedMinistry(ministry.id);
    }
  }

  /// Watch selected ministry for real-time updates
  void _watchSelectedMinistry(String ministryId) {
    _ministrySubscription?.cancel();
    _ministrySubscription = _watchMinistryUseCase(ministryId).listen(
      (updatedMinistry) {
        if (updatedMinistry == null) {
          // Ministry was deleted, remove from selection
          final updatedMinistries = state.ministries
              .where((m) => m.id != ministryId)
              .toList();
          state = state.copyWith(
            ministries: updatedMinistries,
            selectedMinistry: updatedMinistries.isNotEmpty
                ? updatedMinistries.first
                : null,
          );
        } else {
          // Update ministry in the list and selected ministry
          final updatedMinistries = state.ministries.map((m) {
            if (m.id == ministryId) {
              return updatedMinistry;
            }
            return m;
          }).toList();

          state = state.copyWith(
            ministries: updatedMinistries,
            selectedMinistry: updatedMinistry,
          );
        }
      },
      onError: (error) {
        state = state.copyWith(
          error: 'Failed to watch ministry: ${error.toString()}',
        );
      },
    );
  }

  /// Update ministry name
  Future<bool> updateMinistry({
    required String ministryId,
    required String name,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _updateMinistryUseCase(ministryId: ministryId, name: name);

      // Update in local state
      final updatedMinistries = state.ministries.map((m) {
        if (m.id == ministryId) {
          return Ministry(
            id: m.id,
            name: name,
            createdAt: m.createdAt,
            administratorId: m.administratorId,
            logoUrl: m.logoUrl,
          );
        }
        return m;
      }).toList();

      Ministry? updatedSelected = state.selectedMinistry;
      if (state.selectedMinistry?.id == ministryId) {
        updatedSelected = updatedMinistries.firstWhere(
          (m) => m.id == ministryId,
        );
      }

      state = state.copyWith(
        ministries: updatedMinistries,
        selectedMinistry: updatedSelected,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to update ministry: ${e.toString()}',
      );
      return false;
    }
  }

  /// Pick image from gallery or camera
  Future<void> pickImage({required bool fromCamera}) async {
    try {
      final XFile? image = fromCamera
          ? await _imagePicker.pickImage(source: ImageSource.camera)
          : await _imagePicker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        state = state.copyWith(error: 'Photo selection cancelled');
        return;
      }

      final imageBytes = await image.readAsBytes();
      state = state.copyWith(
        selectedImage: imageBytes,
        selectedImagePath: image.path,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to pick image: ${e.toString()}');
    }
  }

  /// Upload ministry logo
  Future<bool> uploadLogo(String ministryId) async {
    if (state.selectedImage == null) {
      return false;
    }

    state = state.copyWith(isSaving: true, error: null);
    try {
      final logoUrl = await _uploadMinistryLogoUseCase(
        ministryId: ministryId,
        imageData: state.selectedImage!,
      );

      // Update in local state
      final updatedMinistries = state.ministries.map((m) {
        if (m.id == ministryId) {
          return Ministry(
            id: m.id,
            name: m.name,
            createdAt: m.createdAt,
            administratorId: m.administratorId,
            logoUrl: logoUrl,
          );
        }
        return m;
      }).toList();

      Ministry? updatedSelected = state.selectedMinistry;
      if (state.selectedMinistry?.id == ministryId) {
        updatedSelected = updatedMinistries.firstWhere(
          (m) => m.id == ministryId,
        );
      }

      state = state.copyWith(
        ministries: updatedMinistries,
        selectedMinistry: updatedSelected,
        selectedImage: null,
        selectedImagePath: null,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to upload logo: ${e.toString()}',
      );
      return false;
    }
  }

  /// Delete ministry
  Future<bool> deleteMinistry(String ministryId) async {
    state = state.copyWith(isDeleting: true, error: null);
    try {
      await _deleteMinistryUseCase(ministryId);

      // Remove from local state
      final updatedMinistries = state.ministries
          .where((m) => m.id != ministryId)
          .toList();

      // Update selected ministry if it was deleted
      Ministry? updatedSelected = state.selectedMinistry;
      if (state.selectedMinistry?.id == ministryId) {
        updatedSelected = updatedMinistries.isNotEmpty
            ? updatedMinistries.first
            : null;
      }

      state = state.copyWith(
        ministries: updatedMinistries,
        selectedMinistry: updatedSelected,
        isDeleting: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Failed to delete ministry: ${e.toString()}',
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    _ministrySubscription?.cancel();
    _ministrySubscription = null;
    _ministriesListSubscription?.cancel();
    _ministriesListSubscription = null;
    state = const MinistryState.initial();
  }

  @override
  void dispose() {
    _ministrySubscription?.cancel();
    _ministriesListSubscription?.cancel();
    super.dispose();
  }
}

/// State for ministry operations
class MinistryState {
  const MinistryState({
    required this.isLoading,
    required this.isCreating,
    required this.isSaving,
    required this.isDeleting,
    this.ministries = const [],
    this.selectedMinistry,
    this.preferredMinistryId,
    this.selectedImage,
    this.selectedImagePath,
    this.error,
  });

  const MinistryState.initial()
    : isLoading = false,
      isCreating = false,
      isSaving = false,
      isDeleting = false,
      ministries = const [],
      selectedMinistry = null,
      preferredMinistryId = null,
      selectedImage = null,
      selectedImagePath = null,
      error = null;

  final bool isLoading;
  final bool isCreating;
  final bool isSaving;
  final bool isDeleting;
  final List<Ministry> ministries;
  final Ministry? selectedMinistry;
  final String? preferredMinistryId;
  final List<int>? selectedImage;
  final String? selectedImagePath;
  final String? error;

  MinistryState copyWith({
    bool? isLoading,
    bool? isCreating,
    bool? isSaving,
    bool? isDeleting,
    List<Ministry>? ministries,
    Ministry? selectedMinistry,
    String? preferredMinistryId,
    List<int>? selectedImage,
    String? selectedImagePath,
    String? error,
  }) {
    return MinistryState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      ministries: ministries ?? this.ministries,
      selectedMinistry: selectedMinistry ?? this.selectedMinistry,
      preferredMinistryId: preferredMinistryId ?? this.preferredMinistryId,
      selectedImage: selectedImage ?? this.selectedImage,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      error: error,
    );
  }
}

/// Provider for ministry controller
final ministryControllerProvider =
    StateNotifierProvider<MinistryController, MinistryState>((ref) {
      final authState = ref.watch(authControllerProvider);
      final userId = authState.user?.uid;
      final preferencesService = ref.watch(preferencesServiceProvider);

      return MinistryController(
        createMinistryUseCase: ref.watch(createMinistryUseCaseProvider),
        getMinistriesByUserUseCase: ref.watch(
          getMinistriesByUserUseCaseProvider,
        ),
        updateMinistryUseCase: ref.watch(updateMinistryUseCaseProvider),
        uploadMinistryLogoUseCase: ref.watch(uploadMinistryLogoUseCaseProvider),
        deleteMinistryUseCase: ref.watch(deleteMinistryUseCaseProvider),
        watchMinistryUseCase: ref.watch(watchMinistryUseCaseProvider),
        watchMinistriesByUserUseCase: ref.watch(
          watchMinistriesByUserUseCaseProvider,
        ),
        imagePicker: ImagePicker(),
        preferencesService: preferencesService,
        userId: userId,
      );
    });
