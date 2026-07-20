import 'dart:io';
import 'dart:vmservice_io';

void main() async {
  try {
    final socket = await Socket.connect('localhost', 12345);
  } catch (e) {
    print(e.toString());
  }
}
