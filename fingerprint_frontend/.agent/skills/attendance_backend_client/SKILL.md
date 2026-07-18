---
name: attendance-backend-client
description: "توفر هذه المهارة هيكل وموديلات ونماذج الاتصال (HTTP & WebSockets) بلغة Dart لربط تطبيق Flutter Desktop مع الـ Backend."
---

# مهارة الربط والاتصال بالـ Backend لتطبيق Flutter Desktop

توفر هذه المهارة التوصيف والشيفرات البرمجية الجاهزة بلغة Dart لتسهيل بناء واجهة الاتصال (API Client) وتلقي بيانات الأجهزة الحية عبر الـ WebSockets من الـ Backend.

---

## 1. نماذج البيانات بلغة Dart (Dart Data Models)

فيما يلي تمثيل حقول المخرجات والمدخلات الخاصة بالـ Backend إلى كائنات Dart مع دعم التحويل من وإلى JSON (`fromJson` & `toJson`).

### 1.1 نموذج المستخدم والتوكن (Auth Models)
```dart
class UserResponse {
  final int id;
  final String username;
  final String role;
  final int? employeeId;

  UserResponse({
    required this.id,
    required this.username,
    required this.role,
    this.employeeId,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
      employeeId: json['employee_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'employee_id': employeeId,
    };
  }
}

class TokenResponse {
  final String token;
  final String refreshToken;
  final UserResponse user;

  TokenResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
```

### 1.2 نموذج الموظف (Employee Model)
```dart
class EmployeeModel {
  final int uid;
  final String employeeId;
  final String name;
  final String role;
  final String? groupId;
  final int? cardNo;
  final int? defaultShiftId;
  final bool isActive;

  EmployeeModel({
    required this.uid,
    required this.employeeId,
    required this.name,
    required this.role,
    this.groupId,
    this.cardNo,
    this.defaultShiftId,
    required this.isActive,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      uid: json['uid'] as int,
      employeeId: json['employee_id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      groupId: json['group_id'] as String?,
      cardNo: json['card_no'] as int?,
      defaultShiftId: json['default_shift_id'] as int?,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'name': name,
      'role': role,
      'group_id': groupId,
      'card_no': cardNo,
      'default_shift_id': defaultShiftId,
      'is_active': isActive,
    };
  }
}
```

### 1.3 نموذج سجلات الحضور الخام والمعالجة (Attendance Models)
```dart
class AttendanceLog {
  final int id;
  final int? employeeId;
  final String? unrecognizedBiometric;
  final int? deviceId;
  final DateTime punchTime;
  final String state; // 'in' or 'out'

  AttendanceLog({
    required this.id,
    this.employeeId,
    this.unrecognizedBiometric,
    this.deviceId,
    required this.punchTime,
    required this.state,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int?,
      unrecognizedBiometric: json['unrecognized_biometric'] as String?,
      deviceId: json['device_id'] as int?,
      punchTime: DateTime.parse(json['punch_time'] as String),
      state: json['state'] as String,
    );
  }
}

class AttendanceRecord {
  final int id;
  final int employeeId;
  final int payrollPeriodId;
  final String recordDate;
  final double totalHours;
  final int latenessMins;
  final int overtimeMins;
  final bool isLocked;
  final String? flags;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.payrollPeriodId,
    required this.recordDate,
    required this.totalHours,
    required this.latenessMins,
    required this.overtimeMins,
    required this.isLocked,
    this.flags,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      payrollPeriodId: json['payroll_period_id'] as int,
      recordDate: json['record_date'] as String,
      totalHours: (json['total_hours'] as num).toDouble(),
      latenessMins: json['lateness_mins'] as int,
      overtimeMins: json['overtime_mins'] as int,
      isLocked: json['is_locked'] as bool,
      flags: json['flags'] as String?,
    );
  }
}
```

### 1.4 نموذج الوردية (Shift Model)
```dart
class ShiftModel {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final String cutOffTime;
  final String weekendDays;
  final int inGracePeriodMins;
  final int outGracePeriodMins;
  final int minOvertimeMins;

  ShiftModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.cutOffTime,
    required this.weekendDays,
    required this.inGracePeriodMins,
    required this.outGracePeriodMins,
    required this.minOvertimeMins,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] as int,
      name: json['name'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      cutOffTime: json['cut_off_time'] as String,
      weekendDays: json['weekend_days'] as String,
      inGracePeriodMins: json['in_grace_period_mins'] as int,
      outGracePeriodMins: json['out_grace_period_mins'] as int,
      minOvertimeMins: json['min_overtime_mins'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'cut_off_time': cutOffTime,
      'weekend_days': weekendDays,
      'in_grace_period_mins': inGracePeriodMins,
      'out_grace_period_mins': outGracePeriodMins,
      'min_overtime_mins': minOvertimeMins,
    };
  }
}
```

### 1.5 نموذج الأجهزة البيومترية (Biometric Device Model)
```dart
class DeviceModel {
  final int id;
  final String name;
  final String deviceType;
  final String ipAddress;
  final int port;
  final bool isOnline;
  final DateTime? lastSync;

  DeviceModel({
    required this.id,
    required this.name,
    required this.deviceType,
    required this.ipAddress,
    required this.port,
    required this.isOnline,
    this.lastSync,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      deviceType: json['device_type'] as String,
      ipAddress: json['ip_address'] as String,
      port: json['port'] as int,
      isOnline: json['is_online'] as bool,
      lastSync: json['last_sync'] != null
          ? DateTime.parse(json['last_sync'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'device_type': deviceType,
      'ip_address': ipAddress,
      'port': port,
    };
  }
}
```

---

## 2. مستودع العميل البرمجي (Dart API Client)

هذه الفئة تدير الجلسة، تحافظ على التوكنات، وتقوم بتحديث الـ Access Token تلقائياً باستخدام الـ Refresh Token عند الضرورة.

### تثبيت الحزم المطلوبة في Flutter:
أضف الحزمة التالية في ملف `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.2.0
```

### فئة اتصال HTTP الأساسية:
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceApiClient {
  final String baseUrl;
  String? _accessToken;
  String? _refreshToken;

  AttendanceApiClient({required this.baseUrl});

  // تحديث التوكنات المحفوظة
  void updateTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  // الحصول على الترويسات الافتراضية
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // دالة الطلبات العامة مع التحديث التلقائي للتوكن عند انتهاء الصلاحية
  async Future<http.Response> _sendRequest(
    String method,
    String path, {
    Map<String, String>? queryParams,
    dynamic body,
  }) async {
    Uri uri = Uri.parse('$baseUrl$path');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
    }

    final headers = _getHeaders();
    final bodyStr = body != null ? jsonEncode(body) : null;
    http.Response response;

    // إرسال الطلب الأصلي
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: bodyStr);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: bodyStr);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    // إذا انتهت صلاحية التوكن (401) وكان لدينا Refresh Token، نحاول التجديد
    if (response.statusCode == 401 && _refreshToken != null && path != '/api/auth/login') {
      final refreshSuccess = await _tryRefreshToken();
      if (refreshSuccess) {
        // إعادة المحاولة بالتوكن الجديد
        final newHeaders = _getHeaders();
        switch (method.toUpperCase()) {
          case 'GET':
            return await http.get(uri, headers: newHeaders);
          case 'POST':
            return await http.post(uri, headers: newHeaders, body: bodyStr);
          case 'PUT':
            return await http.put(uri, headers: newHeaders, body: bodyStr);
          case 'DELETE':
            return await http.delete(uri, headers: newHeaders);
        }
      }
    }

    return response;
  }

  // محاولة تجديد التوكن
  Future<bool> _tryRefreshToken() async {
    final uri = Uri.parse('$baseUrl/api/auth/refresh');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['token'];
        _refreshToken = data['refreshToken'];
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ============================================
  // عمليات المصادقة (Authentication)
  // ============================================

  Future<TokenResponse?> login(String username, String password) async {
    final res = await _sendRequest(
      'POST',
      '/api/auth/login',
      body: {'username': username, 'password': password},
    );
    if (res.statusCode == 200) {
      final tokenRes = TokenResponse.fromJson(jsonDecode(res.body));
      updateTokens(tokenRes.token, tokenRes.refreshToken);
      return tokenRes;
    }
    return null;
  }

  Future<void> logout() async {
    await _sendRequest('POST', '/api/auth/logout');
    _accessToken = null;
    _refreshToken = null;
  }

  // ============================================
  // عمليات إدارة الموظفين (Employees)
  // ============================================

  Future<List<EmployeeModel>> getEmployees() async {
    final res = await _sendRequest('GET', '/api/employees/');
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((e) => EmployeeModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load employees');
  }

  Future<EmployeeModel> createEmployee(Map<String, dynamic> data) async {
    final res = await _sendRequest('POST', '/api/employees/', body: data);
    if (res.statusCode == 201) {
      return EmployeeModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create employee: ${res.body}');
  }

  Future<EmployeeModel> getEmployee(int uid) async {
    final res = await _sendRequest('GET', '/api/employees/$uid');
    if (res.statusCode == 200) {
      return EmployeeModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Employee not found');
  }

  Future<EmployeeModel> updateEmployee(int uid, Map<String, dynamic> data) async {
    final res = await _sendRequest('PUT', '/api/employees/$uid', body: data);
    if (res.statusCode == 200) {
      return EmployeeModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to update employee');
  }

  Future<void> deleteEmployee(int uid) async {
    final res = await _sendRequest('DELETE', '/api/employees/$uid');
    if (res.statusCode != 200) {
      throw Exception('Failed to delete employee');
    }
  }

  // ============================================
  // عمليات الحضور والانصراف (Attendance)
  // ============================================

  Future<List<AttendanceLog>> getAttendanceLogs({int? employeeId, int? deviceId}) async {
    final params = <String, String>{};
    if (employeeId != null) params['employee_id'] = employeeId.toString();
    if (deviceId != null) params['device_id'] = deviceId.toString();

    final res = await _sendRequest('GET', '/api/attendance/logs', queryParams: params);
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((e) => AttendanceLog.fromJson(e)).toList();
    }
    throw Exception('Failed to load attendance logs');
  }

  Future<List<AttendanceRecord>> getAttendanceRecords({int? employeeId, int? payrollPeriodId}) async {
    final params = <String, String>{};
    if (employeeId != null) params['employee_id'] = employeeId.toString();
    if (payrollPeriodId != null) params['payroll_period_id'] = payrollPeriodId.toString();

    final res = await _sendRequest('GET', '/api/attendance/records', queryParams: params);
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((e) => AttendanceRecord.fromJson(e)).toList();
    }
    throw Exception('Failed to load attendance records');
  }
}
```

---

## 3. التعامل مع قنوات الـ WebSocket الحية (Live WebSockets)

للاستماع لنبضات الأجهزة وبث البصمات مباشرة في شاشات الإدارة، يفضل إنشاء فئة مستمعة بالـ WebSocket.

### تثبيت الحزمة المطلوبة:
```yaml
dependencies:
  web_socket_channel: ^3.0.1
```

### فئة إدارة الـ WebSocket:
```dart
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
    _channel!.sink.add(jsonEncode({
      'type': 'register',
      'device_id': deviceId,
    }));
  }

  // إرسال نبضة القلب (Heartbeat)
  void sendHeartbeat(int deviceId) {
    if (!_isConnected) return;
    _channel!.sink.add(jsonEncode({
      'type': 'heartbeat',
      'device_id': deviceId,
    }));
  }

  // إغلاق الاتصال
  void close() {
    _channel?.sink.close();
    _isConnected = false;
  }
}
```
