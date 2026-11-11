import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Central place for environment-specific configuration. Nothing else in
/// the app should ever hardcode a URL — change it here.
class AppConfig {
  AppConfig._(); // prevents instantiation — this class is a static namespace

  // ---- EDIT THESE TWO LINES FOR YOUR SETUP -------------------------------
  //
  // Testing on a PHYSICAL phone: set _usePhysicalDevice = true and put your
  // PC's LAN IP below (run `ipconfig` on Windows, look for the IPv4 Address
  // under your Wi-Fi adapter, e.g. 192.168.1.42). Phone and PC must be on
  // the same Wi-Fi network.
  //
  // Testing on an Android EMULATOR: set _usePhysicalDevice = false.
  static const bool _usePhysicalDevice = true;
  static const String _lanHost = '192.168.1.100';
  // ------------------------------------------------------------------------

  static const int _port = 3000;

  static String get apiBaseUrl {
    if (kIsWeb) {
      // Flutter web running in a browser talks to localhost directly.
      return 'http://localhost:$_port';
    }
    if (Platform.isAndroid) {
      // The emulator maps the host machine's localhost to 10.0.2.2 —
      // 'localhost' inside the emulator refers to the emulator itself.
      // A physical phone can't use that alias, so it needs the LAN IP.
      return _usePhysicalDevice
          ? 'http://$_lanHost:$_port'
          : 'http://10.0.2.2:$_port';
    }
    // iOS simulator can reach localhost directly.
    return 'http://localhost:$_port';
  }
}
