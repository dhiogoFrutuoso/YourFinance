import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool useBiometrics;
  SettingsState({this.useBiometrics = false});
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return SettingsState();
  }

  void toggleBiometrics(bool value) {
    state = SettingsState(useBiometrics: value);
    // TODO: persist this setting using SharedPreferences or Hive
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

