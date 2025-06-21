// filepath: lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost/project_uas1/php-backend/public';

  // Fungsi edit wisata
  Future<bool> editWisata(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/edit_wisata.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['success'] == true;
    }
    return false;
  }
  // Tambah data wisata
  Future<bool> addWisata(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api.php/wisata'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }
}