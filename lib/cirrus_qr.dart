import 'dart:async';
import 'package:flutter/services.dart';

enum ImageSource {
  gallery
}
class CirrusQr {
  static const MethodChannel _channel =
  const MethodChannel('cirrus_qr');

  static Future<dynamic> pickImage(){
    return _channel.invokeMethod('pickImage');
  }
}
