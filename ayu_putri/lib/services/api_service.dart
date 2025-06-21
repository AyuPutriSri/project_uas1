// filepath: ayu_putri/lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Import ini

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Pastikan ini!

  // Ambil data wisata (Tidak ada perubahan di sini)
  Future<List<dynamic>> getWisata() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_wisata.php'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('records')) {
          return data['records'];
        } else {
          return [];
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load wisata: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching wisata: $e');
      throw Exception('Failed to connect to the server or parse data.');
    }
  }

  // Tambah data wisata (dengan file)
  Future<bool> addWisata(Map<String, String> data, XFile? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/add_wisata.php'),
      );

      // Tambahkan field data teks
      request.fields.addAll(data);

      // Tambahkan file jika ada
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto', // Nama field di PHP untuk file
          imageFile.path,
          // contentType: MediaType('image', 'jpeg'), // Opsional: Tentukan tipe konten
        ));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Add Wisata Response Status: ${response.statusCode}');
      print('Add Wisata Response Body: $responseBody');

      if (response.statusCode == 201) {
        final result = jsonDecode(responseBody);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error adding wisata: $e');
      return false;
    }
  }

  // Edit data wisata (dengan file)
  Future<bool> editWisata(Map<String, String> data, XFile? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST', // Menggunakan POST seperti di PHP Anda
        Uri.parse('$baseUrl/edit_wisata.php'),
      );

      // Tambahkan field data teks
      request.fields.addAll(data);

      // Tambahkan file jika ada
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto', // Nama field di PHP untuk file
          imageFile.path,
        ));
      } else if (data['id'] != null) {
        // Jika tidak ada file baru dipilih, tapi ini edit, pertahankan foto lama
        // Kirim 'foto' sebagai string kosong atau null jika tidak ada perubahan
        // Backend perlu menangani jika foto tidak dikirim sebagai file baru
        request.fields['foto_url_lama'] = data['foto'] ?? ''; // Kirim URL lama jika ada
      }


      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Edit Wisata Response Status: ${response.statusCode}');
      print('Edit Wisata Response Body: $responseBody');

      if (response.statusCode == 200) {
        final result = jsonDecode(responseBody);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error editing wisata: $e');
      return false;
    }
  }

  // Hapus data wisata (Tidak ada perubahan di sini)
  Future<bool> deleteWisata(int id) async {
    try {
      final response = await http.post(
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