import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ministryhub/ministryhub.dart';

/// Provider for settings repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final firestoreDatasource = FirestoreDatasource();
  final storageDatasource = StorageDatasource();
  return SettingsRepositoryImpl(
    firestoreDatasource: firestoreDatasource,
    storageDatasource: storageDatasource,
  );
});

/// Provider for use cases
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return DeleteAccountUseCase(repository);
});

final uploadProfilePhotoUseCaseProvider = Provider<UploadProfilePhotoUseCase>((
  ref,
) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UploadProfilePhotoUseCase(repository);
});

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetUserProfileUseCase(repository);
});

/// Controller for account settings
class SettingsController extends StateNotifier<SettingsState> {
  SettingsController({
    required UpdateProfileUseCase updateProfileUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required UploadProfilePhotoUseCase uploadProfilePhotoUseCase,
    required GetUserProfileUseCase getUserProfileUseCase,
    required ImagePicker imagePicker,
  }) : _updateProfileUseCase = updateProfileUseCase,
       _deleteAccountUseCase = deleteAccountUseCase,
       _uploadProfilePhotoUseCase = uploadProfilePhotoUseCase,
       _getUserProfileUseCase = getUserProfileUseCase,
       _imagePicker = imagePicker,
       super(const SettingsState.initial());

  final UpdateProfileUseCase _updateProfileUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final UploadProfilePhotoUseCase _uploadProfilePhotoUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final ImagePicker _imagePicker;

  /// Load user profile
  Future<void> loadProfile(String uid, {String? displayName}) async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _getUserProfileUseCase(uid);

      // If profile doesn't exist in Firestore, try to extract from displayName
      String? initialFirstName = profile?.firstName;
      String? initialLastName = profile?.lastName;

      if (initialFirstName == null &&
          initialLastName == null &&
          displayName != null) {
        final nameParts = displayName
            .trim()
            .split(' ')
            .where((p) => p.isNotEmpty)
            .toList();
        if (nameParts.isNotEmpty) {
          initialFirstName = nameParts.first;
          if (nameParts.length > 1) {
            initialLastName = nameParts.skip(1).join(' ');
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        profile: profile,
        firstName: initialFirstName ?? '',
        lastName: initialLastName ?? '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update first name
  void updateFirstName(String firstName) {
    state = state.copyWith(firstName: firstName);
  }

  /// Update last name
  void updateLastName(String lastName) {
    state = state.copyWith(lastName: lastName);
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

  /// Save profile changes
  Future<bool> saveProfile(String uid) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      String? photoUrl;
      String? profilePhotoPath;

      // Upload photo if selected
      if (state.selectedImage != null) {
        photoUrl = await _uploadProfilePhotoUseCase(
          uid: uid,
          imageData: state.selectedImage!,
        );
        profilePhotoPath = 'users/$uid/profile.jpg';
      }

      // Only update fields that have been modified
      // Compare with original profile to determine what changed
      final originalFirstName = state.profile?.firstName ?? '';
      final originalLastName = state.profile?.lastName ?? '';

      // Only pass firstName if it changed from the original
      String? firstNameToUpdate;
      if (state.firstName != originalFirstName) {
        firstNameToUpdate = state.firstName.isNotEmpty ? state.firstName : null;
      }

      // Only pass lastName if it changed from the original
      String? lastNameToUpdate;
      if (state.lastName != originalLastName) {
        lastNameToUpdate = state.lastName.isNotEmpty ? state.lastName : null;
      }

      // Update profile - only send fields that actually changed
      await _updateProfileUseCase(
        uid: uid,
        firstName: firstNameToUpdate,
        lastName: lastNameToUpdate,
        photoUrl: photoUrl,
        profilePhotoPath: profilePhotoPath,
      );

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to update profile: ${e.toString()}',
      );
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount(String uid) async {
    state = state.copyWith(isDeleting: true, error: null);
    try {
      await _deleteAccountUseCase(uid);
      state = state.copyWith(isDeleting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Failed to delete account: ${e.toString()}',
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
    state = const SettingsState.initial();
  }
}

/// State for settings
class SettingsState {
  const SettingsState({
    required this.isLoading,
    required this.isSaving,
    required this.isDeleting,
    this.profile,
    this.firstName = '',
    this.lastName = '',
    this.selectedImage,
    this.selectedImagePath,
    this.error,
  });

  const SettingsState.initial()
    : isLoading = false,
      isSaving = false,
      isDeleting = false,
      profile = null,
      firstName = '',
      lastName = '',
      selectedImage = null,
      selectedImagePath = null,
      error = null;

  final bool isLoading;
  final bool isSaving;
  final bool isDeleting;
  final UserProfile? profile;
  final String firstName;
  final String lastName;
  final List<int>? selectedImage;
  final String? selectedImagePath;
  final String? error;

  SettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isDeleting,
    UserProfile? profile,
    String? firstName,
    String? lastName,
    List<int>? selectedImage,
    String? selectedImagePath,
    String? error,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      profile: profile ?? this.profile,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      selectedImage: selectedImage ?? this.selectedImage,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      error: error,
    );
  }
}

/// Provider for settings controller
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
      return SettingsController(
        updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
        deleteAccountUseCase: ref.watch(deleteAccountUseCaseProvider),
        uploadProfilePhotoUseCase: ref.watch(uploadProfilePhotoUseCaseProvider),
        getUserProfileUseCase: ref.watch(getUserProfileUseCaseProvider),
        imagePicker: ImagePicker(),
      );
    });
