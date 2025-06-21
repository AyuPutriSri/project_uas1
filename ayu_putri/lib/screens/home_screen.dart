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

  // Dummy data
  List<Map<String, dynamic>> _dummyWisataList = [
    {
      'id': 1,
      'nama': 'Kelingking Beach',
      'lokasi': 'Kabupaten Klungkung',
      'deskripsi': 'Pantai indah dengan tebing curam di Nusa Penida.',
      'foto': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'kategori': 'Pantai',
      'harga': 'Rp 25.000',
    },
    {
      'id': 2,
      'nama': 'Gunung Agung',
      'lokasi': 'Kabupaten Karangasem',
      'deskripsi': 'Gunung tertinggi di Bali, tujuan pendakian populer.',
      'foto': 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'kategori': 'Gunung',
      'harga': 'Rp 0',
    },
    {
      'id': 3,
      'nama': 'Tirta Gangga',
      'lokasi': 'Kabupaten Karangasem',
      'deskripsi': 'Kolam labirin peninggalan kerajaan yang indah.',
      'foto': 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'kategori': 'Taman',
      'harga': 'Rp 20.000',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (_wisataList.isEmpty) {
      _wisataList = List.from(_dummyWisataList);
    }
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
        _fetchWisata();
      }
    }
  }

  // Widget untuk menampilkan halaman Home (daftar wisata) dengan TextField pencarian di dalamnya
  Widget _buildHomePageContent() { // Ubah nama metode ini
    // Filter data berdasarkan _searchTerm
    List<dynamic> filteredWisata = _wisataList.where((wisata) {
      final nama = wisata['nama'].toString().toLowerCase();
      final lokasi = wisata['lokasi'].toString().toLowerCase();
      final searchTerm = _searchTerm.toLowerCase();
      return nama.contains(searchTerm) || lokasi.contains(searchTerm);
    }).toList();

    return Column( // Tambahkan Column di sini
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
          child: _isLoading
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
                      ? const Center(child: Text('Tidak ada data wisata ditemukan.'))
                      : ListView.builder(
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(wisata: wisata, isAdmin: true),
                                    ),
                                  ).then((_) => _fetchWisata());
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
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.image, size: 40),
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
                                            const SizedBox(height: 4.0),
                                            Text(
                                              'Lokasi: ${wisata['lokasi'] ?? 'Tidak Diketahui'}',
                                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              'Kategori: ${wisata['kategori'] ?? 'Tidak Ada'}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, color: Colors.grey),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Daftar Wisata' : 'Profil User'),
        backgroundColor: Colors.blueAccent,
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchWisata,
                ),
              ]
            : null,
      ),
      body: _selectedIndex == 0 ? _buildHomePageContent() : ProfileScreen(), // Panggil _buildHomePageContent() atau ProfileScreen()
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddEditScreen()),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}