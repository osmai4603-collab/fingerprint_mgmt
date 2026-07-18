import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class BiometricWebSocketClient {
  final String wsUrl;
  WebSocketChannel? _channel;
  bool _isConnected = false;

  BiometricWebSocketClient({required this.wsUrl});

  // فتح الاتصال
  void connect({
    required Function(Map<String, dynamic> data) onMessageReceived,
    required Function(dynamic error) onError,
    required Function() onDone,
  }) {
    if (_isConnected) return;

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _isConnected = true;

    _channel!.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message as String);
          onMessageReceived(data);
        } catch (_) {}
      },
      onError: (err) {
        _isConnected = false;
        onError(err);
      },
      onDone: () {
        _isConnected = false;
        onDone();
      },
    );
  }

  // إرسال رسالة تسجيل الجهاز
  void registerDevice(int deviceId) {
    if (!_isConnected) return;
    _channel!.sink.add(jsonEncode({'type': 'register', 'device_id': deviceId}));
  }

  // إرسال نبضة القلب (Heartbeat)
  void sendHeartbeat(int deviceId) {
    if (!_isConnected) return;
    _channel!.sink.add(
      jsonEncode({'type': 'heartbeat', 'device_id': deviceId}),
    );
  }

  // إغلاق الاتصال
  void close() {
    _channel?.sink.close();
    _isConnected = false;
  }
}
