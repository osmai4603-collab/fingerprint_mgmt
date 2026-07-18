import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

enum BackendStatus {
  initializing,
  checkingFiles,
  startingPostgres,
  postgresReady,
  creatingDatabase,
  startingBackend,
  backendReady,
  ready,
  error,
  stopped,
}

enum BackendComponent {
  postgres,
  backend,
}

class BackendInitProgress {
  final BackendStatus status;
  final String message;
  final double progress;
  final String? error;

  const BackendInitProgress({
    required this.status,
    required this.message,
    this.progress = 0.0,
    this.error,
  });
}

class BackendManager {
  final String appName = 'fingerprint_mgmt';
  final int postgresPort;
  final int backendPort;
  final Duration startupTimeout;
  final Duration healthCheckInterval;

  late final String bundleDir;
  late final String userDataDir;
  late final String pgDataDir;
  late final String pgLogDir;
  late final String pgLogFile;
  late final String backendLogFile;
  late final String? postgresBinDir;
  late final String? backendExePath;
  late final String? migrationsDir;

  Process? _postgresProcess;
  Process? _backendProcess;

  final _progressController = StreamController<BackendInitProgress>.broadcast();
  Stream<BackendInitProgress> get progressStream => _progressController.stream;

  BackendStatus _status = BackendStatus.initializing;
  BackendStatus get status => _status;

  final String _lastErrorMessage = '';
  String get lastErrorMessage => _lastErrorMessage;

  final int _pgPort;
  int get effectivePostgresPort => _pgPort;

  BackendManager({
    this.postgresPort = 5433,
    this.backendPort = 8000,
    this.startupTimeout = const Duration(seconds: 60),
    this.healthCheckInterval = const Duration(milliseconds: 500),
  }) : _pgPort = postgresPort;

  bool get isProductionMode {
    if (backendExePath == null) return false;
    return File(backendExePath!).existsSync();
  }

  void _emitProgress(BackendStatus status, String message,
      {double progress = 0.0, String? error}) {
    _status = status;
    _progressController.add(BackendInitProgress(
      status: status,
      message: message,
      progress: progress,
      error: error,
    ));
  }

  Future<void> initialize() async {
    _emitProgress(BackendStatus.checkingFiles, 'التحقق من ملفات التطبيق...',
        progress: 0.05);

    await _resolvePaths();

    if (isProductionMode) {
      await _startPostgres();
      await _startBackend();
    } else {
      _emitProgress(BackendStatus.ready,
          'وضع التطوير - سيتم الاتصال بالخادم الخارجي',
          progress: 1.0);
    }
  }

  Future<void> shutdown() async {
    await _stopBackend();
    await _stopPostgres();
    _emitProgress(BackendStatus.stopped, 'تم إيقاف التطبيق', progress: 0);
    await _progressController.close();
  }

  Future<void> _resolvePaths() async {
    final exeFile = File(Platform.resolvedExecutable);
    bundleDir = exeFile.parent.path;

    if (Platform.isLinux) {
      final home = Platform.environment['HOME'] ?? '/tmp';
      userDataDir = '$home/.local/share/$appName';
    } else if (Platform.isWindows) {
      final appData =
          Platform.environment['APPDATA'] ?? 'C:/Users/Default/AppData/Roaming';
      userDataDir = '$appData/$appName';
    } else {
      userDataDir = '/tmp/$appName';
    }

    pgDataDir = '$userDataDir/pgdata';
    pgLogDir = '$userDataDir/pg_log';
    pgLogFile = '$pgLogDir/postgres.log';
    backendLogFile = '$userDataDir/backend.log';

    final separator = Platform.isWindows ? '\\' : '/';
    final backendDir = '$bundleDir${separator}backend';

    if (Platform.isWindows) {
      backendExePath = '$backendDir\\backend_server.exe';
    } else {
      backendExePath = '$backendDir/backend_server';
    }


    migrationsDir = '$backendDir${separator}migrations';

    final pgBase = '$bundleDir${separator}postgres';
    final pgBinDir = '$pgBase${separator}bin';
    if (Directory(pgBinDir).existsSync()) {
      postgresBinDir = pgBinDir;
    } else {
      postgresBinDir = null;
    }
  }

  Future<void> _startPostgres() async {
    _emitProgress(BackendStatus.startingPostgres, 'جاري تشغيل قاعدة البيانات...',
        progress: 0.15);

    if (postgresBinDir == null) {
      _emitProgress(BackendStatus.postgresReady,
          'لم يتم العثور على PostgreSQL المضمن',
          progress: 0.3);
      return;
    }

    Directory(pgDataDir).createSync(recursive: true);
    Directory(pgLogDir).createSync(recursive: true);

    final pgCtl = '$postgresBinDir${Platform.isWindows ? '\\' : '/'}pg_ctl';
    final initdb = '$postgresBinDir${Platform.isWindows ? '\\' : '/'}initdb';

    if (!Directory(pgDataDir).listSync().any((e) =>
        e is File && e.path.endsWith('postgresql.conf'))) {
      _emitProgress(
          BackendStatus.startingPostgres, 'جاري تهيئة قاعدة البيانات لأول مرة...',
          progress: 0.2);

      final initResult = await Process.run(initdb, [
        '-D', pgDataDir,
        '--auth-host=trust',
        '--auth-local=trust',
        '--username=postgres',
        '--pwfile=${_createPasswordFile()}',
      ]);

      if (initResult.exitCode != 0) {
        _emitProgress(BackendStatus.error,
            'فشل تهيئة قاعدة البيانات: ${initResult.stderr}',
            progress: 0, error: initResult.stderr.toString());
        return;
      }
    }

    _emitProgress(BackendStatus.startingPostgres, 'جاري بدء تشغيل PostgreSQL...',
        progress: 0.3);

    _postgresProcess = await Process.start(pgCtl, [
      'start',
      '-D', pgDataDir,
      '-l', pgLogFile,
      '-w',
      '-o', '-p $_pgPort',
    ]);

    _postgresProcess!.stderr
        .transform(utf8.decoder)
        .listen((data) => debugPrint('[postgres stderr] $data'));

    _postgresProcess!.stdout
        .transform(utf8.decoder)
        .listen((data) => debugPrint('[postgres stdout] $data'));

    _postgresProcess!.exitCode.then((code) {
      debugPrint('[postgres] exited with code $code');
    });

    bool ready = false;
    final deadline = DateTime.now().add(startupTimeout);

    while (!ready && DateTime.now().isBefore(deadline)) {
      try {
        final pgIsready = '$postgresBinDir${Platform.isWindows ? '\\' : '/'}pg_isready';
        final result = await Process.run(pgIsready, [
          '-h', 'localhost',
          '-p', '$_pgPort',
        ]);
        if (result.exitCode == 0) {
          ready = true;
        }
      } catch (_) {}

      if (!ready) {
        await Future.delayed(healthCheckInterval);
      }

      final elapsed = DateTime.now().difference(deadline).inMilliseconds;
      final total = startupTimeout.inMilliseconds;
      _emitProgress(
        BackendStatus.startingPostgres,
        'جاري بدء تشغيل PostgreSQL...',
        progress: 0.3 + (0.2 * (1 - elapsed / total)),
      );
    }

    if (!ready) {
      _emitProgress(
        BackendStatus.error,
        'فشل تشغيل PostgreSQL - انتهت المهلة',
        progress: 0,
        error: 'Timeout starting PostgreSQL on port $_pgPort',
      );
      return;
    }

    _emitProgress(BackendStatus.postgresReady, 'قاعدة البيانات جاهزة',
        progress: 0.5);

    await _createDatabaseIfNeeded();
  }

  String _createPasswordFile() {
    final file = File('$userDataDir/pg_password.tmp');
    file.writeAsStringSync('postgres');
    return file.path;
  }

  Future<void> _createDatabaseIfNeeded() async {
    _emitProgress(BackendStatus.creatingDatabase,
        'جاري التحقق من وجود قاعدة البيانات...',
        progress: 0.55);

    if (postgresBinDir == null) return;

    final createdb =
        '$postgresBinDir${Platform.isWindows ? '\\' : '/'}createdb';

    final result = await Process.run(createdb, [
      '-h', 'localhost',
      '-p', '$_pgPort',
      '-U', 'postgres',
      'fingerprint_db',
    ]);

    if (result.exitCode != 0) {
      final stderr = result.stderr.toString().toLowerCase();
      if (stderr.contains('already exists')) {
        debugPrint('[postgres] Database already exists');
      } else {
        debugPrint('[postgres] createdb warning: ${result.stderr}');
      }
    }

    _emitProgress(BackendStatus.postgresReady, 'قاعدة البيانات جاهزة',
        progress: 0.6);
  }

  Future<void> _startBackend() async {
    _emitProgress(BackendStatus.startingBackend, 'جاري تشغيل الخادم...',
        progress: 0.65);

    if (backendExePath == null || !File(backendExePath!).existsSync()) {
      _emitProgress(BackendStatus.backendReady,
          'لم يتم العثور على ملف الخادم',
          progress: 0.7);
      return;
    }

    final env = {
      'STANDALONE_BACKEND': '1',
      'DB_HOST': 'localhost',
      'DB_PORT': _pgPort.toString(),
      'DB_NAME': 'fingerprint_db',
      'DB_USER': 'postgres',
      'DB_PASSWORD': 'postgres',
      'JWT_SECRET': 'standalone-jwt-secret-${DateTime.now().millisecondsSinceEpoch}',
      'JWT_EXPIRY_HOURS': '24',
      'JWT_REFRESH_EXPIRY_DAYS': '30',
      'BACKEND_PORT': backendPort.toString(),
      'BACKEND_HOST': '127.0.0.1',
      'MIGRATIONS_DIR': migrationsDir ?? '',
    };

    final logFile = File(backendLogFile);
    logFile.createSync(recursive: true);
    final logSink = logFile.openWrite(mode: FileMode.append);

    _backendProcess = await Process.start(
      backendExePath!,
      [],
      environment: env,
    );

    _backendProcess!.stdout
        .transform(utf8.decoder)
        .listen((data) {
      logSink.write(data);
      debugPrint('[backend stdout] $data');
    });

    _backendProcess!.stderr
        .transform(utf8.decoder)
        .listen((data) {
      logSink.write(data);
      debugPrint('[backend stderr] $data');
    });

    _backendProcess!.exitCode.then((code) {
      logSink.close();
      debugPrint('[backend] exited with code $code');
    });

    // Backend started

    bool ready = false;
    final deadline = DateTime.now().add(startupTimeout);
    final client = HttpClient();

    while (!ready && DateTime.now().isBefore(deadline)) {
      try {
        final request = await client
            .getUrl(Uri.parse('http://127.0.0.1:$backendPort/health'));
        final response = await request.close();
        if (response.statusCode == 200) {
          ready = true;
        }
      } catch (_) {}

      if (!ready) {
        await Future.delayed(healthCheckInterval);
      }

      final elapsed = deadline.difference(DateTime.now()).inMilliseconds;
      final total = startupTimeout.inMilliseconds;
      _emitProgress(
        BackendStatus.startingBackend,
        'جاري تشغيل الخادم...',
        progress: 0.65 + (0.3 * (1 - elapsed / total)),
      );
    }

    client.close(force: true);

    if (!ready) {
      _emitProgress(
        BackendStatus.error,
        'فشل تشغيل الخادم - انتهت المهلة',
        progress: 0,
        error: 'Timeout waiting for backend on port $backendPort',
      );
      return;
    }

    _emitProgress(
        BackendStatus.ready, 'التطبيق جاهز للاستخدام', progress: 1.0);
  }

  Future<void> _stopBackend() async {
    if (_backendProcess != null) {
      try {
        _backendProcess!.kill(ProcessSignal.sigterm);
        await _backendProcess!.exitCode.timeout(
          const Duration(seconds: 5),
          onTimeout: () => -1,
        );
      } catch (_) {}
      _backendProcess = null;
    }
  }

  Future<void> _stopPostgres() async {
    if (postgresBinDir != null && Directory(pgDataDir).existsSync()) {
      final pgCtl = '$postgresBinDir${Platform.isWindows ? '\\' : '/'}pg_ctl';
      try {
        await Process.run(pgCtl, [
          'stop',
          '-D', pgDataDir,
          '-m', 'fast',
        ]);
      } catch (_) {}
    }

    if (_postgresProcess != null) {
      try {
        _postgresProcess!.kill(ProcessSignal.sigterm);
        await _postgresProcess!.exitCode.timeout(
          const Duration(seconds: 5),
          onTimeout: () => -1,
        );
      } catch (_) {}
      _postgresProcess = null;
    }
  }

  bool checkBackendHealth() {
    try {
      final client = HttpClient();
      client
          .getUrl(Uri.parse('http://127.0.0.1:$backendPort/health'))
          .then((req) => req.close().then((resp) {
                client.close();
                return resp.statusCode == 200;
              }));
      return true;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _progressController.close();
  }
}
