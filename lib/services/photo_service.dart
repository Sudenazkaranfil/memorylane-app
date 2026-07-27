import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'storage_service.dart';

class PhotoService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<String> uploadPhoto(String filePath, int entryId) async {
    final token = await StorageService.getToken();
    final file = File(filePath);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/entries/$entryId/photos'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['url'];
    } else {
      throw Exception('Fotoğraf yüklenemedi');
    }
  }
}