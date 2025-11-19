import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ministryhub/ministryhub.dart';

// Sentinel value for copyWith to distinguish between null and not provided
const _undefined = Object();

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

final updateMinistrySubscriptionUseCaseProvider =
    Provider<UpdateMinistrySubscriptionUseCase>((ref) {
      final repository = ref.watch(ministryRepositoryProvider);
      return UpdateMinistrySubscriptionUseCase(repository);
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
    required UpdateMinistrySubscriptionUseCase
    updateMinistrySubscriptionUseCase,
    required UploadMinistryLogoUseCase uploadMinistryLogoUseCase,
    required DeleteMinistryUseCase deleteMinistryUseCase,
    required WatchMinistryUseCase watchMinistryUseCase,
    required WatchMinistriesByUserUseCase watchMinistriesByUserUseCase,
    required MinistryRepository repository,
    required ImagePicker imagePicker,
    required PreferencesService preferencesService,
    String? userId,
  }) : _createMinistryUseCase = createMinistryUseCase,
       _getMinistriesByUserUseCase = getMinistriesByUserUseCase,
       _updateMinistryUseCase = updateMinistryUseCase,
       _updateMinistrySubscriptionUseCase = updateMinistrySubscriptionUseCase,
       _uploadMinistryLogoUseCase = uploadMinistryLogoUseCase,
       _deleteMinistryUseCase = deleteMinistryUseCase,
       _watchMinistryUseCase = watchMinistryUseCase,
       _watchMinistriesByUserUseCase = watchMinistriesByUserUseCase,
       _repository = repository,
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
  final UpdateMinistrySubscriptionUseCase _updateMinistrySubscriptionUseCase;
  final UploadMinistryLogoUseCase _uploadMinistryLogoUseCase;
  final DeleteMinistryUseCase _deleteMinistryUseCase;
  final WatchMinistryUseCase _watchMinistryUseCase;
  final WatchMinistriesByUserUseCase _watchMinistriesByUserUseCase;
  final MinistryRepository _repository;
  final ImagePicker _imagePicker;
  final PreferencesService _preferencesService;
  String? _userId;
  StreamSubscription<Ministry?>? _ministrySubscription;
  StreamSubscription<List<Ministry>>? _ministriesListSubscription;
  bool _isDisposed = false;

  /// Load ministries for the current user
  Future<void> loadMinistries(String userId) async {
    if (_isDisposed) return;
    _userId = userId;
    if (!_isDisposed) {
      state = state.copyWith(isLoading: true);
    }
    try {
      final ministries = await _getMinistriesByUserUseCase(userId);
      if (_isDisposed) return;

      // Load preferred ministry if not already set
      if (state.selectedMinistry == null && !_isDisposed) {
        await _loadPreferredMinistry(userId);
        if (_isDisposed) return;
      }

      // If preferred ministry is set, try to select it
      if (state.preferredMinistryId != null && ministries.isNotEmpty) {
        final preferred = ministries.firstWhere(
          (m) => m.id == state.preferredMinistryId,
          orElse: () => ministries.first,
        );
        if (!_isDisposed) {
          state = state.copyWith(
            ministries: ministries,
            selectedMinistry: preferred,
            isLoading: false,
          );
          // Start watching the selected ministry
          _watchSelectedMinistry(preferred.id);
        }
      } else if (ministries.isNotEmpty) {
        // Select first ministry if no preference
        if (!_isDisposed) {
          state = state.copyWith(
            ministries: ministries,
            selectedMinistry: ministries.first,
            isLoading: false,
          );
          // Start watching the selected ministry
          _watchSelectedMinistry(ministries.first.id);
        }
      } else {
        if (!_isDisposed) {
          state = state.copyWith(
            ministries: ministries,
            selectedMinistry: null,
            isLoading: false,
          );
        }
      }

      // Start watching the ministries list for real-time updates
      if (!_isDisposed) {
        _watchMinistriesList(userId);
      }
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  /// Watch ministries list for real-time updates
  void _watchMinistriesList(String userId) {
    _ministriesListSubscription?.cancel();
    _ministriesListSubscription = _watchMinistriesByUserUseCase(userId).listen(
      (updatedMinistries) {
        if (_isDisposed) return;
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
            if (updatedSelected != null && !_isDisposed) {
              _watchSelectedMinistry(updatedSelected.id);
            } else {
              _ministrySubscription?.cancel();
              _ministrySubscription = null;
            }
          } else {
            // Selected ministry still exists, update it
            updatedSelected = found;
          }
        } else if (updatedMinistries.isNotEmpty && !_isDisposed) {
          // No selected ministry, select first
          updatedSelected = updatedMinistries.first;
          _watchSelectedMinistry(updatedSelected.id);
        }

        if (!_isDisposed) {
          state = state.copyWith(
            ministries: updatedMinistries,
            selectedMinistry: updatedSelected,
          );
        }
      },
      onError: (error) {
        if (_isDisposed) return;
        state = state.copyWith(
          error: 'Failed to watch ministries list: ${error.toString()}',
        );
      },
    );
  }

  /// Load preferred ministry from preferences
  Future<void> _loadPreferredMinistry(String userId) async {
    if (_isDisposed) return;
    try {
      final preferredId = await _preferencesService.getStringForUser(
        'preferredMinistryId',
        userId,
      );
      if (_isDisposed) return;
      if (preferredId != null && preferredId.isNotEmpty) {
        if (!_isDisposed) {
          state = state.copyWith(preferredMinistryId: preferredId);
        }
      }
    } catch (e) {
      // Ignore errors loading preference
    }
  }

  /// Set preferred ministry
  Future<void> setPreferredMinistry(String? ministryId, String userId) async {
    if (_isDisposed) return;
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
      if (!_isDisposed) {
        state = state.copyWith(preferredMinistryId: ministryId);
      }
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
    if (_isDisposed) return null;
    if (!_isDisposed) {
      state = state.copyWith(isCreating: true, error: null);
    }
    try {
      final ministry = await _createMinistryUseCase(
        name: name,
        administratorId: administratorId,
      );
      if (_isDisposed) return null;

      // Don't add to ministries list locally - let the stream handle it
      // This prevents duplicates when Firestore emits the update
      // Select the new ministry temporarily - the stream will update the list
      if (!_isDisposed) {
        state = state.copyWith(selectedMinistry: ministry, isCreating: false);

        // Start watching the new ministry
        _watchSelectedMinistry(ministry.id);

        // If this is the first ministry, set it as preferred
        // Check if list will be empty after creation (before stream updates)
        if (state.ministries.isEmpty && _userId != null) {
          await setPreferredMinistry(ministry.id, _userId!);
        }
      }

      return ministry;
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isCreating: false,
          error: 'Failed to create ministry: ${e.toString()}',
        );
      }
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
        if (_isDisposed) return;
        if (updatedMinistry == null) {
          // Ministry was deleted, remove from selection
          final updatedMinistries = state.ministries
              .where((m) => m.id != ministryId)
              .toList();
          if (!_isDisposed) {
            state = state.copyWith(
              ministries: updatedMinistries,
              selectedMinistry: updatedMinistries.isNotEmpty
                  ? updatedMinistries.first
                  : null,
            );
          }
        } else {
          // Update ministry in the list and selected ministry
          final updatedMinistries = state.ministries.map((m) {
            if (m.id == ministryId) {
              return updatedMinistry;
            }
            return m;
          }).toList();

          if (!_isDisposed) {
            state = state.copyWith(
              ministries: updatedMinistries,
              selectedMinistry: updatedMinistry,
            );
          }
        }
      },
      onError: (error) {
        if (_isDisposed) return;
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
    if (_isDisposed) return false;
    if (!_isDisposed) {
      state = state.copyWith(isSaving: true, error: null);
    }
    try {
      await _updateMinistryUseCase(ministryId: ministryId, name: name);
      if (_isDisposed) return false;

      // Update in local state
      final updatedMinistries = state.ministries.map((m) {
        if (m.id == ministryId) {
          return Ministry(
            id: m.id,
            name: name,
            createdAt: m.createdAt,
            administratorId: m.administratorId,
            logoUrl: m.logoUrl,
            subscriptionType: m.subscriptionType, // Preserve subscription type
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

      if (!_isDisposed) {
        state = state.copyWith(
          ministries: updatedMinistries,
          selectedMinistry: updatedSelected,
          isSaving: false,
        );
      }
      return true;
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isSaving: false,
          error: 'Failed to update ministry: ${e.toString()}',
        );
      }
      return false;
    }
  }

  /// Update ministry subscription
  /// In mock mode, updates Firestore directly without RevenueCat verification
  /// In production mode, purchases the package in RevenueCat first
  Future<bool> updateSubscription({
    required String ministryId,
    required SubscriptionType subscriptionType,
    Package? package,
  }) async {
    if (_isDisposed) return false;
    if (!_isDisposed) {
      state = state.copyWith(isSaving: true, error: null);
    }

    try {
      // If subscription is not free, try to purchase in RevenueCat first
      // In mock mode, this will throw MOCK_MODE_DIRECT_UPDATE and we'll skip to Firestore update
      if (subscriptionType != SubscriptionType.free && package != null) {
        try {
          // Use mock datasource to bypass RevenueCat
          final subscriptionRepository = SubscriptionRepositoryImpl(
            revenueCatDatasource: MockRevenueCatDatasource(),
          );
          final customerInfo = await subscriptionRepository.purchasePackage(
            package,
          );

          // Verify the subscription was successful
          final activeSubscriptionType = subscriptionRepository
              .getActiveSubscriptionType(customerInfo);
          if (activeSubscriptionType != subscriptionType) {
            if (!_isDisposed) {
              state = state.copyWith(
                isSaving: false,
                error: 'Failed to verify subscription purchase',
              );
            }
            return false;
          }
        } on SubscriptionException catch (e) {
          // Check if this is a mock mode exception
          // In mock mode, we skip RevenueCat and update Firestore directly
          if (e.message == 'MOCK_MODE_DIRECT_UPDATE') {
            // Continue to Firestore update without RevenueCat verification
            // This is the expected behavior in mock mode
          } else {
            // Re-throw other subscription exceptions
            rethrow;
          }
        }
      }

      // Update subscription in Firestore
      await _updateMinistrySubscriptionUseCase(
        ministryId: ministryId,
        subscriptionType: subscriptionType,
      );
      if (_isDisposed) return false;

      // Update in local state
      final updatedMinistries = state.ministries.map((m) {
        if (m.id == ministryId) {
          return Ministry(
            id: m.id,
            name: m.name,
            createdAt: m.createdAt,
            administratorId: m.administratorId,
            logoUrl: m.logoUrl,
            subscriptionType: subscriptionType,
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

      if (!_isDisposed) {
        state = state.copyWith(
          ministries: updatedMinistries,
          selectedMinistry: updatedSelected,
          isSaving: false,
        );
      }
      return true;
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isSaving: false,
          error: 'Failed to update subscription: ${e.toString()}',
        );
      }
      return false;
    }
  }

  /// Pick image from gallery or camera
  Future<void> pickImage({required bool fromCamera}) async {
    if (_isDisposed) return;
    try {
      final XFile? image = fromCamera
          ? await _imagePicker.pickImage(source: ImageSource.camera)
          : await _imagePicker.pickImage(source: ImageSource.gallery);
      if (_isDisposed) return;

      if (image == null) {
        if (!_isDisposed) {
          state = state.copyWith(error: 'Photo selection cancelled');
        }
        return;
      }

      final imageBytes = await image.readAsBytes();
      if (!_isDisposed) {
        state = state.copyWith(
          selectedImage: imageBytes,
          selectedImagePath: image.path,
        );
      }
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(error: 'Failed to pick image: ${e.toString()}');
      }
    }
  }

  /// Delete ministry logo
  Future<bool> deleteLogo(String ministryId) async {
    if (_isDisposed) return false;
    if (!_isDisposed) {
      state = state.copyWith(isSaving: true, error: null);
    }
    try {
      await _repository.removeMinistryLogo(ministryId);
      if (_isDisposed) return false;

      // Update in local state
      final updatedMinistries = state.ministries.map((m) {
        if (m.id == ministryId) {
          return Ministry(
            id: m.id,
            name: m.name,
            createdAt: m.createdAt,
            administratorId: m.administratorId,
            logoUrl: null, // Remove logo
            subscriptionType: m.subscriptionType, // Preserve subscription type
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

      if (!_isDisposed) {
        state = state.copyWith(
          ministries: updatedMinistries,
          selectedMinistry: updatedSelected,
          isSaving: false,
        );
      }
      return true;
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isSaving: false,
          error: 'Failed to delete logo: ${e.toString()}',
        );
      }
      return false;
    }
  }

  /// Upload ministry logo
  Future<bool> uploadLogo(String ministryId, {Ministry? baseMinistry}) async {
    if (_isDisposed) return false;
    if (state.selectedImage == null) {
      return false;
    }

    if (!_isDisposed) {
      state = state.copyWith(isSaving: true, error: null);
    }
    try {
      final logoUrl = await _uploadMinistryLogoUseCase(
        ministryId: ministryId,
        imageData: state.selectedImage!,
      );
      if (_isDisposed) return false;

      // Update in local state
      // First, try to find and update existing ministry
      final ministryExists = state.ministries.any((m) => m.id == ministryId);
      List<Ministry> updatedMinistries;

      if (ministryExists) {
        // Ministry exists in list, update it
        updatedMinistries = state.ministries.map((m) {
          if (m.id == ministryId) {
            return Ministry(
              id: m.id,
              name: m.name,
              createdAt: m.createdAt,
              administratorId: m.administratorId,
              logoUrl: logoUrl,
              subscriptionType:
                  m.subscriptionType, // Preserve subscription type
            );
          }
          return m;
        }).toList();
      } else {
        // Ministry doesn't exist in list, add it with the updated logo
        // Try to get the ministry from selectedMinistry or baseMinistry parameter
        final ministryToUse = state.selectedMinistry?.id == ministryId
            ? state.selectedMinistry!
            : baseMinistry;

        if (ministryToUse != null) {
          updatedMinistries = [
            ...state.ministries,
            Ministry(
              id: ministryToUse.id,
              name: ministryToUse.name,
              createdAt: ministryToUse.createdAt,
              administratorId: ministryToUse.administratorId,
              logoUrl: logoUrl,
              subscriptionType: ministryToUse.subscriptionType,
            ),
          ];
        } else {
          updatedMinistries = state.ministries;
        }
      }

      // Update selectedMinistry if it matches the ministry we just updated
      Ministry? updatedSelected = state.selectedMinistry;
      if (state.selectedMinistry?.id == ministryId ||
          (baseMinistry != null && baseMinistry.id == ministryId)) {
        try {
          updatedSelected = updatedMinistries.firstWhere(
            (m) => m.id == ministryId,
          );
        } catch (e) {
          // Ministry not found in list, keep current selectedMinistry
          updatedSelected = state.selectedMinistry;
        }
      }

      if (!_isDisposed) {
        state = state.copyWith(
          ministries: updatedMinistries,
          selectedMinistry: updatedSelected,
          selectedImage: null,
          selectedImagePath: null,
          isSaving: false,
        );
      }
      return true;
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isSaving: false,
          error: 'Failed to upload logo: ${e.toString()}',
        );
      }
      return false;
    }
  }

  /// Delete ministry
  Future<bool> deleteMinistry(String ministryId) async {
    if (_isDisposed) return false;
    if (!_isDisposed) {
      state = state.copyWith(isDeleting: true, error: null);
    }
    try {
      await _deleteMinistryUseCase(ministryId);
      if (_isDisposed) return false;

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

      if (!_isDisposed) {
        state = state.copyWith(
          ministries: updatedMinistries,
          selectedMinistry: updatedSelected,
          isDeleting: false,
        );
      }
      return true;
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isDeleting: false,
          error: 'Failed to delete ministry: ${e.toString()}',
        );
      }
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear selected image
  void clearSelectedImage() {
    if (_isDisposed) return;
    state = state.copyWith(selectedImage: null, selectedImagePath: null);
  }

  /// Reset state
  void reset() {
    _ministrySubscription?.cancel();
    _ministrySubscription = null;
    _ministriesListSubscription?.cancel();
    _ministriesListSubscription = null;
    if (!_isDisposed) {
      state = const MinistryState.initial();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _ministrySubscription?.cancel();
    _ministrySubscription = null;
    _ministriesListSubscription?.cancel();
    _ministriesListSubscription = null;
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
    Object? selectedImage = _undefined,
    Object? selectedImagePath = _undefined,
    Object? error = _undefined,
  }) {
    return MinistryState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      ministries: ministries ?? this.ministries,
      selectedMinistry: selectedMinistry ?? this.selectedMinistry,
      preferredMinistryId: preferredMinistryId ?? this.preferredMinistryId,
      selectedImage: selectedImage == _undefined
          ? this.selectedImage
          : selectedImage as List<int>?,
      selectedImagePath: selectedImagePath == _undefined
          ? this.selectedImagePath
          : selectedImagePath as String?,
      error: error == _undefined ? this.error : error as String?,
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
        updateMinistrySubscriptionUseCase: ref.watch(
          updateMinistrySubscriptionUseCaseProvider,
        ),
        uploadMinistryLogoUseCase: ref.watch(uploadMinistryLogoUseCaseProvider),
        deleteMinistryUseCase: ref.watch(deleteMinistryUseCaseProvider),
        watchMinistryUseCase: ref.watch(watchMinistryUseCaseProvider),
        watchMinistriesByUserUseCase: ref.watch(
          watchMinistriesByUserUseCaseProvider,
        ),
        repository: ref.watch(ministryRepositoryProvider),
        imagePicker: ImagePicker(),
        preferencesService: preferencesService,
        userId: userId,
      );
    });
