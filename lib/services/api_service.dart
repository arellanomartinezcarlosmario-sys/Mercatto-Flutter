import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Configura la URL al ejecutar con:
/// flutter run --dart-define=API_BASE_URL=https://TU-BACKEND
class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mercatto-backend.onrender.com',
  );

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers()).timeout(const Duration(seconds: 25));
    return _decode(response);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(Uri.parse('$baseUrl$path'), headers: await _headers(), body: jsonEncode(body)).timeout(const Duration(seconds: 25));
    return _decode(response);
  }

  static dynamic _decode(http.Response response) {
    dynamic data;
    try { data = jsonDecode(utf8.decode(response.bodyBytes)); } catch (_) { data = response.body; }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map ? (data['mensaje'] ?? data['message'] ?? data['error']) : null;
      throw Exception(message?.toString() ?? 'Error del servidor (${response.statusCode})');
    }
    return data;
  }
}
