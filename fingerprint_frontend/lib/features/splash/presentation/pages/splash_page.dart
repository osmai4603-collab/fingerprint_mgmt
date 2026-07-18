import 'dart:async';
import 'package:fingerprint_frontend/core/constants/app_route_keys.dart';
import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/services/backend_manager.dart';
import 'package:fingerprint_frontend/core/di/injection_container.dart' as di;
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final BackendManager _manager;
  BackendInitProgress _progress = const BackendInitProgress(
    status: BackendStatus.initializing,
    message: 'جاري تهيئة التطبيق...',
  );
  StreamSubscription<BackendInitProgress>? _subscription;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _manager = di.get_it<BackendManager>();
    _startInitialization();
  }

  void _startInitialization() async {
    _subscription = _manager.progressStream.listen(_onProgress);
    await _manager.initialize();
  }

  void _onProgress(BackendInitProgress progress) {
    if (!mounted) return;

    setState(() {
      _progress = progress;
      if (progress.status == BackendStatus.error) {
        _hasError = true;
      }
    });
    if (progress.status == BackendStatus.ready) {
      _onReady();
    }
  }

  void _onReady() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      context.go(AppRouteKeys.login);
    });
  }

  Future<void> _retry() async {
    _subscription?.cancel();
    _manager.dispose();
    await _manager.shutdown();

    final newManager = BackendManager();
    _subscription = newManager.progressStream.listen(_onProgress);
    newManager.initialize();
  }

  IconData _getStatusIcon(BackendStatus status) {
    switch (status) {
      case BackendStatus.initializing:
      case BackendStatus.checkingFiles:
      case BackendStatus.startingPostgres:
      case BackendStatus.creatingDatabase:
      case BackendStatus.startingBackend:
        return Icons.hourglass_top;
      case BackendStatus.postgresReady:
      case BackendStatus.backendReady:
        return Icons.check_circle_outline;
      case BackendStatus.ready:
        return Icons.check_circle;
      case BackendStatus.error:
        return Icons.error_outline;
      case BackendStatus.stopped:
        return Icons.stop_circle_outlined;
    }
  }

  Color _getStatusColor(BackendStatus status) {
    switch (status) {
      case BackendStatus.initializing:
      case BackendStatus.checkingFiles:
      case BackendStatus.startingPostgres:
      case BackendStatus.creatingDatabase:
      case BackendStatus.startingBackend:
      case BackendStatus.postgresReady:
      case BackendStatus.backendReady:
        return Colors.blue;
      case BackendStatus.ready:
        return Colors.green;
      case BackendStatus.error:
        return Colors.red;
      case BackendStatus.stopped:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'نظام إدارة البصمات',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              if (_progress.status == BackendStatus.error) ...[
                Icon(
                  _getStatusIcon(_progress.status),
                  size: 48,
                  color: _getStatusColor(_progress.status),
                ),
                const SizedBox(height: 16),
                Text(
                  _progress.error ?? _progress.message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_hasError)
                  FilledButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
              ] else ...[
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: _progress.progress > 0 && _progress.progress < 1.0
                        ? _progress.progress
                        : null,
                    color: _getStatusColor(_progress.status),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _progress.message,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_progress.progress > 0 && _progress.progress < 1.0)
                  LinearProgressIndicator(
                    value: _progress.progress,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
