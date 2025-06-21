import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'detail_screen.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List wisata (dummy data, bisa diganti dengan data dari API)
  List<Map<String, dynamic>> wisataList = [
    {
      'nama': 'Kelingking Beach',
      'lokasi': 'Kabupaten Klungkung',
      'deskripsi': 'Pantai indah dengan tebing curam.',
      'foto': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      'kategori': 'Pantai',
      'harga': 'Rp 25.000',
    },
    {
      'nama': 'Gunung Agung',
      'lokasi': 'Kabupaten Karangasem',
      'deskripsi': 'Gunung tertinggi di Bali.',
      'foto': 'https://images.unsplash.com/photo-1464983953574-0892a716854b',
      'kategori': 'Gunung',
      'harga': 'Rp 0',
    },
    {
      'nama': 'Tirta Gangga',
      'lokasi': 'Kabupaten Karangasem',
      'deskripsi': 'Kolam labirin peninggalan kerajaan.',
      'foto': 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429',
      'kategori': 'Taman',
      'harga': 'Rp 20.000',
    },
  ];

  // Widget halaman utama (list wisata)
  Widget _buildHomePage() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: wisataList.length,
      itemBuilder: (context, index) {
        final wisata = wisataList[index];
        return Card(
          child: ListTile(
            leading: wisata['foto'] != null && wisata['foto'] != ''
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      wisata['foto'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 60),
                    ),
                  )
                : Icon(Icons.image, size: 60),
            title: Text(
              wisata['nama'] ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(wisata['lokasi'] ?? ''),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
            onTap: () async {
              // Navigasi ke halaman detail
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(wisata: wisata, isAdmin: true),
                ),
              );
              // Jika data diedit, update list
              if (result != null && result is Map<String, dynamic>) {
                setState(() {
                  wisataList[index] = result;
                });
              }
            },
          ),
        );
      },
    );
  }

  final Widget _profilePage = ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? _buildHomePage() : _profilePage,
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                // Navigasi ke halaman tambah wisata
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditScreen(),
                  ),
                );
                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    wisataList.add(result);
                  });
                }
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.add),
              tooltip: 'Tambah Wisata',
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}