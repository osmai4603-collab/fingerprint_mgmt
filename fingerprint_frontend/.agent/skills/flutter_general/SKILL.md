---
name: flutter-general-architecture
description: "إرشادات عامة، طبقات شبكية مجردة (Abstract Networking Layers)، وإرشادات التصميم المعماري النظيف (Clean Architecture) لبناء تطبيقات Flutter."
---

# مهارة بنية وتطوير تطبيقات Flutter (العامة والمجردة)

توفر هذه المهارة إطار عمل نظري وتطبيقي مجرد (Abstract) لتنظيم وإدارة كود تطبيقات **Flutter** (خاصة تطبيقات الـ Desktop والـ Mobile) باتباع مبادئ **Clean Architecture** وفصل المسؤوليات، وتوفير طبقة اتصالات عامة وقابلة لإعادة الاستخدام.

---

## 1. الهيكل المعماري المقترح للمشروع (Clean Architecture Directory Structure)

يُنصح بتقسيم التطبيق إلى ثلاث طبقات رئيسية لضمان سهولة الفحص (Testing) والصيانة والتطوير المستقبلي:

```text
lib/
├── core/                         # النواة: الأدوات المشتركة، الإعدادات، والطبقات المجردة العامة
│   ├── network/                  # الاتصالات المجردة (HTTP & WebSockets)
│   ├── theme/                    # المظهر العام والألوان والخطوط
│   ├── utils/                    # الدوال المساعدة العامة (تنسيق تاريخ، نصوص، إلخ)
│   └── error/                    # استثناءات النظام وأخطاء الاتصالات
├── data/                         # طبقة البيانات: التنفيذ الفعلي للخدمات والاتصال بالخادم
│   ├── datasources/              # مصادر البيانات (Local DB, Remote APIs)
│   ├── models/                   # موديلات البيانات (توسيع للـ Entity مع تحويل JSON)
│   └── repositories/             # التنفيذ الفعلي للمستودعات
├── domain/                       # طبقة النطاق: منطق العمل الخالص (خالي من تبعيات الأطر الخارجية)
│   ├── entities/                 # الكائنات الأساسية للأعمال (Business Objects)
│   ├── repositories/             # واجهات المستودعات المجردة (Contracts)
│   └── usecases/                 # حالات الاستخدام الخاصة بالتطبيق
└── presentation/                 # طبقة العرض: واجهات المستخدم وإدارة الحالة
    ├── state/                    # إدارة الحالة (Bloc, Riverpod, or Provider)
    ├── pages/                    # الشاشات الكاملة
    └── widgets/                  # العناصر البرمجية الصغيرة والقابلة لإعادة الاستخدام
```

---

## 2. طبقة اتصالات HTTP مجردة وعامة (Abstract HTTP Client)

إنشاء واجهة برمجية مجردة لخدمة الـ HTTP يسمح بتغيير مكتبة الاتصال بسهولة (مثال: الانتقال من `http` إلى `dio`) دون تعديل المنطق البرمجي للتطبيق.

### 2.1 الواجهة المجردة (HTTP Client Interface)
```dart
abstract class AbstractHttpClient {
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  });

  Future<HttpResponse<T>> post<T>(
    String path, {
    Map<String, String>? headers,
    dynamic body,
  });

  Future<HttpResponse<T>> put<T>(
    String path, {
    Map<String, String>? headers,
    dynamic body,
  });

  Future<HttpResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
  });
}

// كائن استجابة موحد ومجرد
class HttpResponse<T> {
  final T? data;
  final int statusCode;
  final String? message;

  HttpResponse({
    this.data,
    required this.statusCode,
    this.message,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
```

### 2.2 تنفيذ مجرد لواجهة الاستجابة والتعامل مع الأخطاء (Network Exception handling)
```dart
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException({required this.message, this.statusCode});

  @override
  String toString() => 'NetworkException: [$statusCode] $message';
}
```

---

## 3. طبقة اتصالات WebSocket مجردة (Abstract WebSocket Service)

واجهة مجردة لإدارة الاتصالات الحية مع دعم الاستماع التلقائي، وإعادة الاتصال عند الانقطاع.

### 3.1 الواجهة المجردة (WebSocket Client Interface)
```dart
abstract class AbstractWebSocketClient {
  // تيار البيانات المستلمة
  Stream<dynamic> get stream;
  
  // حالة الاتصال الحالية
  bool get isConnected;

  // فتح الاتصال
  Future<void> connect(String url);

  // إرسال بيانات
  void send(dynamic message);

  // إغلاق الاتصال
  Future<void> close();
}
```

### 3.2 فئة معالجة إعادة الاتصال التلقائي (Auto-Reconnect Wrapper)
تُغلف الواجهة البرمجية لإعادة الاتصال تلقائياً عند فقدان الشبكة:
```dart
import 'dart:async';

class ReconnectingWebSocket {
  final AbstractWebSocketClient client;
  final Duration reconnectDelay;
  
  String? _currentUrl;
  bool _shouldReconnect = true;
  Timer? _reconnectTimer;

  // بث خارجي للبيانات المستلمة
  final _controller = StreamController<dynamic>.broadcast();
  Stream<dynamic> get stream => _controller.stream;

  ReconnectingWebSocket({
    required this.client,
    this.reconnectDelay = const Duration(seconds: 5),
  });

  Future<void> connect(String url) async {
    _currentUrl = url;
    _shouldReconnect = true;
    await _attemptConnect();
  }

  Future<void> _attemptConnect() async {
    if (_currentUrl == null) return;
    
    try {
      await client.connect(_currentUrl!);
      
      // الاستماع للتيار وتوجيهه للبث الخارجي
      client.stream.listen(
        (data) => _controller.add(data),
        onError: (err) => _handleDisconnect(),
        onDone: () => _handleDisconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    if (!_shouldReconnect) return;
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () {
      if (_shouldReconnect) {
        _attemptConnect();
      }
    });
  }

  void send(dynamic message) {
    if (client.isConnected) {
      client.send(message);
    }
  }

  Future<void> close() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    await client.close();
    await _controller.close();
  }
}
```

---

## 4. نموذج المستودعات النظيف (Generic Repository Pattern)

فصل واجهات جلب البيانات عن تنفيذها يتيح للواجهات الرسومية طلب البيانات دون معرفة مصدرها (سواء كان خادم الإنترنت، أو قاعدة بيانات داخلية مثل Hive أو SQLite).

```dart
// العقد/الواجهة البرمجية في طبقة الـ Domain
abstract class GenericRepository<T> {
  Future<List<T>> getAll();
  Future<T> getById(int id);
  Future<T> create(T entity);
  Future<T> update(int id, T entity);
  Future<void> delete(int id);
}
```

---

## 5. أفضل ممارسات تطوير Flutter للـ Desktop

عند بناء واجهات لتطبيقات سطح المكتب (Windows / macOS / Linux)، يجب مراعاة الأمور المعمارية والتشغيلية التالية:

### 5.1 التصميم المتجاوب (Responsive & Adaptive Layouts)
شاشات سطح المكتب تتميز بمساحات واسعة وقابلية لتغيير الحجم. يفضل استخدام عناصر تحكم ديناميكية مثل `LayoutBuilder` أو فئة المساعدة التالية:
```dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return desktop;
        } else if (constraints.maxWidth >= 600) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

### 5.2 إدارة النوافذ والاختصارات (Shortcuts & Window Control)
* **اختصارات لوحة المفاتيح:** استخدم ويدجيت `Shortcuts` و `Actions` لتسهيل استخدام التطبيق بدون الماوس.
* **إدارة حجم النافذة:** استخدم حزم مثل `window_manager` لتعيين الحد الأدنى للحجم ومنع تشويه الواجهة عند تصغير الشاشة جداً.
* **التمرير بالماوس وعجلة الفأرة:** تأكد من أن الـ `Scrollviews` تدعم التمرير السلس للـ Desktop عن طريق توفير `Scrollbar` ظاهرة دائماً للمستخدمين.
