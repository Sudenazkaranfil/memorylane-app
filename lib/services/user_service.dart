import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class UserService {
  static const String baseUrl = 'https://memorylane-wk1y.onrender.com';

  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/search?q=${Uri.encodeComponent(query)}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<Map<String, dynamic>> getUserProfile(String username) async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Kullanıcı bulunamadı');
  }

  static Future<Map<String, dynamic>> getFollowStatus(String username) async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username/follow-status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {'following': false, 'followerCount': 0, 'followingCount': 0};
  }

  static Future<bool> toggleFollow(String username) async {
    final token = await StorageService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/users/$username/follow'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['following'];
    }
    throw Exception('İşlem başarısız');
  }
}