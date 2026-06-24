import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitrapos/core/di/injection.dart';
import 'package:mitrapos/core/network/dio_client.dart';

class SettingsState {
  final bool isLoading;
  final Map<String, dynamic>? appSettings;
  final String? errorMessage;

  SettingsState({
    this.isLoading = false,
    this.appSettings,
    this.errorMessage,
  });

  SettingsState copyWith({
    bool? isLoading,
    Map<String, dynamic>? appSettings,
    String? errorMessage,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      appSettings: appSettings ?? this.appSettings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  final DioClient _dioClient;

  SettingsController(this._dioClient) : super(SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _dioClient.get('/settings');
      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          appSettings: response.data['data'],
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal mengambil pengaturan',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final dioClient = getIt<DioClient>();
  return SettingsController(dioClient);
});
