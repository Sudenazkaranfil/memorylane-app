import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/journal.dart';
import 'storage_service.dart';

class JournalService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<List<Journal>> getJournals() async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/journals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Journal.fromJson(json)).toList();
    } else {
      throw Exception('Ajandalar yüklenemedi');
    }
  }

  static Future<List<Journal>> getPublicJournals({String? search, String? sortBy}) async {
    final token = await StorageService.getToken();
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (sortBy != null) params['sortBy'] = sortBy;

    final uri = Uri.parse('$baseUrl/journals/public').replace(queryParameters: params.isEmpty ? null : params);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Journal.fromJson(json)).toList();
    } else {
      throw Exception('Ajandalar yüklenemedi');
    }
  }

  static Future<Journal> createJournal(String title, String visibility) async {
    final token = await StorageService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/journals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'visibility': visibility,
      }),
    );

    if (response.statusCode == 200) {
      return Journal.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ajanda oluşturulamadı');
    }
  }

  static Future<Journal> updateJournal(int id, String title, String visibility) async {
    final token = await StorageService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/journals/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'visibility': visibility,
      }),
    );

    if (response.statusCode == 200) {
      return Journal.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ajanda güncellenemedi');
    }
  }

  static Future<void> deleteJournal(int id) async {
    final token = await StorageService.getToken();
    await http.delete(
      Uri.parse('$baseUrl/journals/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}