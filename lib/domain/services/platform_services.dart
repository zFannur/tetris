import 'package:flutter/services.dart';

class PlatformService {
  static const MethodChannel platform = MethodChannel('com.example.app/windows');

  static Future<void> exitApp() async {
    try {
      await platform.invokeMethod('exitApp');
    } on PlatformException catch (e) {
      print("Failed to exit app: '${e.message}'");
    }
  }
}