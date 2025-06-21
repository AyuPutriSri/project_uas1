import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_edit_screen.dart';
import 'detail_screen.dart'; // Pastikan ini diimpor

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApiService apiService = ApiService();
  List<dynamic> _wisataList = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWisata();
  }

  Future<void> _fetchWisata() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final data = await apiService.getWisata();
      setState(() {
        _wisataList = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDelete(int id) async {
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
      bool success = await apiService.deleteWisata(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Data berhasil dihapus!' : 'Gagal menghapus data.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        _fetchWisata(); // Refresh data setelah hapus
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Wisata'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWisata,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : _wisataList.isEmpty
                  ? const Center(child: Text('Tidak ada data wisata ditemukan.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _wisataList.length,
                      itemBuilder: (context, index) {
                        final wisata = _wisataList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(wisata: wisata),
                                ),
                              ).then((_) => _fetchWisata()); // Refresh setelah kembali dari detail
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    wisata['nama'] ?? 'Nama Tidak Diketahui',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Lokasi: ${wisata['lokasi'] ?? 'Tidak Diketahui'}',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Kategori: ${wisata['kategori'] ?? 'Tidak Ada'}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.orange),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddEditScreen(wisata: wisata),
                                            ),
                                          );
                                          if (result == true) {
                                            _fetchWisata(); // Refresh data setelah edit
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _confirmDelete(wisata['id']),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditScreen()),
          );
          if (result == true) {
            _fetchWisata(); // Refresh data setelah tambah
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}