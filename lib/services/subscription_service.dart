import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class SubscriptionStatus {
  final String plan;
  final bool isPlus;
  final bool isPro;
  final int journalLimit;
  final int pageLimit;

  const SubscriptionStatus({
    required this.plan,
    required this.isPlus,
    required this.isPro,
    required this.journalLimit,
    required this.pageLimit,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      plan: json['plan']?.toString() ?? 'FREE',
      isPlus: json['isPlus'] ?? false,
      isPro: json['isPro'] ?? false,
      journalLimit: json['journalLimit'] ?? 5,
      pageLimit: json['pageLimit'] ?? 15,
    );
  }
}

class SubscriptionService {
  static const String baseUrl = 'https://memorylane-wk1y.onrender.com';

  static Future<SubscriptionStatus> getStatus() async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/subscription/status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return SubscriptionStatus.fromJson(jsonDecode(response.body));
    }
    throw Exception('Abonelik bilgisi alınamadı');
  }

  static Future<void> registerCustomer(String customerId) async {
    final token = await StorageService.getToken();
    await http.post(
      Uri.parse('$baseUrl/subscription/register-customer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'customerId': customerId}),
    );
  }
}
