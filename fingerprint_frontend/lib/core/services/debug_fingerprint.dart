import 'package:flutter/foundation.dart';

void logPrint({required String title, required Map<String, dynamic> data}) {
  if (kDebugMode) {
    // final keys = data.isEmpty
    //     ? ''
    //    : '\n{\n    ${data.keys.map((key) => '$key: ${data[key]}').join(',\n    ')}\n}';
    print('$title: $data');
  }
}

void logsPrints({
  required String title,
  required List<Map<String, dynamic>> list,
}) {
  if (kDebugMode) {
    for (var data in list) {
      logPrint(title: title, data: data);
    }
  }
}
