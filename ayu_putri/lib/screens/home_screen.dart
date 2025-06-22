// filepath: ayu_putri/lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_edit_screen.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';

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
  int _selectedIndex = 0;
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();

  // Bagian DUMMY DATA sudah dihapus/dikomentari.

  @override
  void initState() {
    super.initState();
    // Inisialisasi tanpa dummy data
    _fetchWisata(); // Hanya fetch data dari API
  }

  Future<void> _fetchWisata() async {
    print('DEBUG: _fetchWisata() called.'); // Debug print
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _wisataList = []; // Memastikan list dikosongkan sebelum fetch
    });
    try {
      final data = await apiService.getWisata();
      setState(() {
        _wisataList = data; // Timpa dengan data asli dari API
        print(
          'DEBUG: Data fetched. List size: ${_wisataList.length}',
        ); // Debug print
      });
    } catch (e) {
      print('DEBUG ERROR: Failed to fetch data: $e'); // Debug print
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
          content: Text(
            success ? 'Data berhasil dihapus!' : 'Gagal menghapus data.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        print(
          'DEBUG: Data successfully deleted from backend. Fetching new data...',
        );
        _fetchWisata(); // Memuat ulang data dari API setelah berhasil hapus
      }
    }
  }

  // Widget untuk menampilkan halaman Home (daftar wisata) dengan TextField pencarian di dalamnya
  Widget _buildHomePageContent() {
    // Filter data berdasarkan _searchTerm
    List<dynamic> filteredWisata =
        _wisataList.where((wisata) {
          final nama = wisata['nama'].toString().toLowerCase();
          final lokasi = wisata['lokasi'].toString().toLowerCase();
          final searchTerm = _searchTerm.toLowerCase();
          return nama.contains(searchTerm) || lokasi.contains(searchTerm);
        }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Cari Wisata...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchTerm = value;
              });
            },
          ),
        ),
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  )
                  : filteredWisata.isEmpty
                  ? const Center(
                    child: Text('Tidak ada data wisata ditemukan.'),
                  )
                  : ListView.builder(
                    key: ValueKey(
                      _wisataList.length,
                    ), // *** TAMBAHKAN KEY INI ***
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredWisata.length,
                    itemBuilder: (context, index) {
                      final wisata = filteredWisata[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DetailScreen(
                                      wisata: wisata,
                                      isAdmin: true,
                                    ),
                              ),
                            );
                            if (result == true) {
                              print(
                                'DEBUG: Returned from DetailScreen with true. Fetching new data...',
                              );
                              _fetchWisata();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                wisata['foto'] != null && wisata['foto'] != ''
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        wisata['foto'],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.image,
                                                    size: 40,
                                                  ),
                                                ),
                                      ),
                                    )
                                    : Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, size: 40),
                                    ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        wisata['nama'] ??
                                            'Nama Tidak Diketahui',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        'Lokasi: ${wisata['lokasi'] ?? 'Tidak Diketahui'}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        'Kategori: ${wisata['kategori'] ?? 'Tidak Ada'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  // final List<Widget> _pages telah dihapus, kontennya langsung di body Scaffold
  // final List<Widget> _pages = [
  //   _HomeScreenContentWrapper(),
  //   ProfileScreen(),
  // ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List halaman untuk BottomNavigationBar (dibuat lokal di build method)
    final List<Widget> _pages = [
      _buildHomePageContent(), // Konten Home
      ProfileScreen(), // Halaman profil Anda
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Daftar Wisata' : 'Profil User'),
        backgroundColor: Colors.blueAccent,
        actions:
            _selectedIndex == 0
                ? [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _fetchWisata,
                  ),
                ]
                : null,
      ),
      body:
          _pages[_selectedIndex], // Tampilkan halaman berdasarkan _selectedIndex
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditScreen(),
                    ),
                  );
                  if (result == true) {
                    _fetchWisata();
                  }
                },
                child: const Icon(Icons.add),
                backgroundColor: Colors.blueAccent,
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

// *** _HomeScreenContentWrapper TIDAK DIPERLUKAN LAGI DAN BISA DIHAPUS ***
// class _HomeScreenContentWrapper extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final _HomeScreenState? parentState = context.findAncestorStateOfType<_HomeScreenState>();
//     return parentState != null ? parentState._buildHomePageContent() : Container();
//   }
// }
