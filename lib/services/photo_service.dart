import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../config/api_config.dart';
import 'storage_service.dart';

class PhotoService {
  static const String baseUrl = ApiConfig.baseUrl;

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

  static Future<String> uploadDirectToCloudinary(String filePath) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/xnzocixe/image/upload');
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = 'memorylane_unsigned';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final data = jsonDecode(body);
      return data['secure_url'];
    }
    throw Exception('Cloudinary yükleme başarısız');
  }
}