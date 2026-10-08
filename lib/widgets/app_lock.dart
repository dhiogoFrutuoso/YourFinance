import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/settings_provider.dart';

class AppLock extends ConsumerStatefulWidget {
  final Widget child;
  const AppLock({super.key, required this.child});
  @override
  ConsumerState<AppLock> createState() => _AppLockState();
}

class _AppLockState extends ConsumerState<AppLock> with WidgetsBindingObserver {
  bool _unlocked = false;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_busy &&
        (state == AppLifecycleState.hidden ||
            state == AppLifecycleState.paused)) {
      setState(() => _unlocked = false);
    }
  }

  Future<void> _unlock() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final success = await LocalAuthentication().authenticate(
        localizedReason: 'Desbloqueie suas finanças',
        persistAcrossBackgrounding: true,
      );
      if (mounted) {
        setState(() {
          _unlocked = success;
          _error = success ? null : 'Autenticação cancelada. Tente novamente.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Não foi possível autenticar. Confira o bloqueio de tela do dispositivo.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(settingsProvider).useBiometrics || _unlocked) {
      return widget.child;
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 56),
                const SizedBox(height: 24),
                const Text(
                  'Suas finanças estão protegidas',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_error != null) Text(_error!, textAlign: TextAlign.center),
                FilledButton.icon(
                  onPressed: _busy ? null : _unlock,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(_busy ? 'Autenticando…' : 'Desbloquear'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
