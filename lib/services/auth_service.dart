/*import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/device_id.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:3000"; // Emulator localhost

  Future<bool> requestCode(String email) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/auth/request-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return resp.statusCode == 200;
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final deviceId = await getOrCreateDeviceId();
    final resp = await http.post(
      Uri.parse('$baseUrl/auth/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'device_id': deviceId,
      }),
    );
    return jsonDecode(resp.body);
  }
}*/

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const baseUrl = "https://v2-hema-costos.onrender.com";

  static Future<bool> requestCode(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/request-code"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return res.statusCode == 200;
  }

  static Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String code,
    required String deviceId,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/verify-code"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "code": code,
        "device_id": deviceId,
      }),
    );

    return jsonDecode(res.body);
  }
}