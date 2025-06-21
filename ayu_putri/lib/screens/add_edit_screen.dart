import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddEditScreen extends StatefulWidget {
  final Map<String, dynamic>? wisata; // null jika tambah, ada jika edit

  AddEditScreen({this.wisata});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController namaController;
  late TextEditingController lokasiController;
  late TextEditingController deskripsiController;
  late TextEditingController fotoController;
  late TextEditingController kategoriController;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.wisata?['nama'] ?? '');
    lokasiController = TextEditingController(
      text: widget.wisata?['lokasi'] ?? '',
    );
    deskripsiController = TextEditingController(
      text: widget.wisata?['deskripsi'] ?? '',
    );
    fotoController = TextEditingController(text: widget.wisata?['foto'] ?? '');
    kategoriController = TextEditingController(
      text: widget.wisata?['kategori'] ?? '',
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    lokasiController.dispose();
    deskripsiController.dispose();
    fotoController.dispose();
    kategoriController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'id': widget.wisata?['id'],
        'nama': namaController.text,
        'lokasi': lokasiController.text,
        'deskripsi': deskripsiController.text,
        'foto': fotoController.text,
        'kategori': kategoriController.text,
      };

      bool success;
      if (widget.wisata == null) {
        // Tambah data
        success = await ApiService().addWisata(data);
      } else {
        // Edit data
        success = await ApiService().editWisata(data);
      }

      if (success) {
        Navigator.pop(context, data);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wisata == null ? 'Tambah Wisata' : 'Edit Wisata'),
        backgroundColor: Colors.green[200],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama Wisata'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: lokasiController,
                decoration: InputDecoration(labelText: 'Lokasi'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: deskripsiController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: fotoController,
                decoration: InputDecoration(labelText: 'URL Foto'),
              ),
              TextFormField(
                controller: kategoriController,
                decoration: InputDecoration(labelText: 'Kategori'),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _saveData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
