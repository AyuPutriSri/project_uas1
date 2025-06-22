// filepath: ayu_putri/lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Pastikan ini di-import
import 'add_edit_screen.dart'; // Pastikan ini di-import

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> wisata;
  final bool isAdmin;

  const DetailScreen({Key? key, required this.wisata, this.isAdmin = false}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  ApiService apiService = ApiService(); // Inisialisasi ApiService di sini

  Future<void> _confirmDelete() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      bool success = await apiService.deleteWisata(widget.wisata['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Data berhasil dihapus!' : 'Gagal menghapus data.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.pop(context, true); // Ini akan mengembalikan `true` ke HomeScreen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Wisata'),
        backgroundColor: Colors.blueAccent,
        // Hapus actions di AppBar jika tombol ada di body
        // actions: widget.isAdmin ? [ /* ... */ ] : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image (Header) - seperti di gambar Anda
            if (widget.wisata['foto'] != null && widget.wisata['foto'] != '')
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.wisata['foto'],
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[300],
                    // Hapus 'const' di sini:
                    child: Icon(Icons.image, size: 100, color: Colors.grey[600]), // <--- UBAH INI
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[300],
                // Hapus 'const' di sini:
                child: Icon(Icons.image, size: 100, color: Colors.grey[600]), // <--- UBAH INI
              ),
            const SizedBox(height: 20),
            Text(
              widget.wisata['nama'] ?? 'Nama Tidak Diketahui',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 20),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    widget.wisata['lokasi'] ?? 'Lokasi Tidak Diketahui',
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.category, color: Colors.grey, size: 20),
                const SizedBox(width: 5),
                Text(
                  'Kategori: ${widget.wisata['kategori'] ?? 'Tidak Ada'}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Deskripsi:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.wisata['deskripsi'] ?? 'Deskripsi tidak tersedia.',
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30), // Spasi sebelum tombol
            if (widget.isAdmin) // Tampilkan tombol hanya jika isAdmin true
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Data'),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditScreen(wisata: widget.wisata),
                          ),
                        );
                        if (result == true) {
                          // Jika ada perubahan dari AddEditScreen, pop juga dari DetailScreen
                          Navigator.pop(context, true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Warna hijau
                        foregroundColor: Colors.white, // Warna teks putih
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus Data'),
                      onPressed: _confirmDelete, // Panggil metode confirm delete
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Warna merah
                        foregroundColor: Colors.white, // Warna teks putih
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}