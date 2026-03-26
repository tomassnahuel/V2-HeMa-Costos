import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;
    return android.id;
  } else if (Platform.isIOS) {
    final ios = await deviceInfo.iosInfo;
    return ios.identifierForVendor ?? "unknown";
  }

  return "unknown_device";
}