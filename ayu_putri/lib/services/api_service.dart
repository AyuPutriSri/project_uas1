import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti IP address ini dengan IP address komputer Anda jika menggunakan emulator Android
  // Jika menggunakan emulator iOS atau mengakses dari perangkat fisik di jaringan yang sama,
  // gunakan IP address komputer Anda (contoh: 'http://192.168.1.10/project_uas1/php-backend/public')
  // Jika menggunakan localhost di emulator (Android Studio emulator), bisa pakai 10.0.2.2
  // Untuk perangkat fisik atau iOS simulator, gunakan IP lokal komputer Anda
  static const String baseUrl = 'http://localhost:8000/project_uas1/php-backend/public'; // Sesuaikan IP ini!

  // Ambil data wisata
  Future<List<dynamic>> getWisata() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_wisata.php'));
      if (response.statusCode == 200) {
        // Menggunakan jsonDecode untuk parse string JSON
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('records')) {
          return data['records'];
        } else {
          // Jika backend tidak mengembalikan 'records', mungkin data kosong atau struktur berbeda
          return [];
        }
      } else if (response.statusCode == 404) {
        // Tidak ada data ditemukan
        return [];
      } else {
        // Tangani error lainnya dari server
        throw Exception('Failed to load wisata: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      // Tangani error jaringan atau parsing JSON
      print('Error fetching wisata: $e');
      throw Exception('Failed to connect to the server or parse data.');
    }
  }

  // Tambah data wisata
  Future<bool> addWisata(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_wisata.php'), // *** PERBAIKAN PENTING DI SINI ***
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      print('Add Wisata Response Status: ${response.statusCode}');
      print('Add Wisata Response Body: ${response.body}');
      return response.statusCode == 201; // HTTP 201 Created untuk sukses tambah data
    } catch (e) {
      print('Error adding wisata: $e');
      return false;
    }
  }

  // Fungsi edit wisata
  Future<bool> editWisata(Map<String, dynamic> data) async {
    try {
      final response = await http.post( // Menggunakan POST seperti di PHP Anda
        Uri.parse('$baseUrl/edit_wisata.php'), // *** PERBAIKAN PENTING DI SINI ***
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      print('Edit Wisata Response Status: ${response.statusCode}');
      print('Edit Wisata Response Body: ${response.body}');
      return response.statusCode == 200; // HTTP 200 OK untuk sukses edit data
    } catch (e) {
      print('Error editing wisata: $e');
      return false;
    }
  }

  // Hapus data wisata
  Future<bool> deleteWisata(int id) async {
    try {
      final response = await http.post( // Menggunakan POST
        Uri.parse('$baseUrl/delete_wisata.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );
      print('Delete Wisata Response Status: ${response.statusCode}');
      print('Delete Wisata Response Body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting wisata: $e');
      return false;
    }
  }
}