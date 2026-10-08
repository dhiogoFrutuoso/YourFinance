import '../utils/formatters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class SettingsState {
  final bool useBiometrics;
  final bool hideAmounts;
  const SettingsState({this.useBiometrics = false, this.hideAmounts = false});
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final prefs = Hive.box<String>('preferences');
    Formatters.hideAmounts = prefs.get('hideAmounts') == 'true';
    return SettingsState(
      useBiometrics: prefs.get('useBiometrics') == 'true',
      hideAmounts: prefs.get('hideAmounts') == 'true',
    );
  }

  Future<void> toggleBiometrics(bool value) async {
    await Hive.box<String>('preferences').put('useBiometrics', '$value');
    state = SettingsState(useBiometrics: value, hideAmounts: state.hideAmounts);
  }

  Future<void> toggleAmounts() async {
    Formatters.hideAmounts = !state.hideAmounts;
    await Hive.box<String>(
      'preferences',
    ).put('hideAmounts', '${!state.hideAmounts}');
    state = SettingsState(
      useBiometrics: state.useBiometrics,
      hideAmounts: !state.hideAmounts,
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
