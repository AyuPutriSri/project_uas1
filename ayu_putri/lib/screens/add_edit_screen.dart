import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddEditScreen extends StatefulWidget {
  final Map<String, dynamic>? wisata; // Nullable for add, not-null for edit

  const AddEditScreen({Key? key, this.wisata}) : super(key: key);

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController(); // Untuk URL foto
  final TextEditingController _kategoriController = TextEditingController();

  ApiService apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Jika mode edit, isi data dari widget.wisata
    if (widget.wisata != null) {
      _namaController.text = widget.wisata!['nama'] ?? '';
      _lokasiController.text = widget.wisata!['lokasi'] ?? '';
      _deskripsiController.text = widget.wisata!['deskripsi'] ?? '';
      _fotoController.text = widget.wisata!['foto'] ?? '';
      _kategoriController.text = widget.wisata!['kategori'] ?? '';
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> data = {
        'nama': _namaController.text,
        'lokasi': _lokasiController.text,
        'deskripsi': _deskripsiController.text,
        'foto': _fotoController.text, // Pastikan ini dikirim
        'kategori': _kategoriController.text, // Pastikan ini dikirim
      };

      bool success;
      String message = '';

      if (widget.wisata == null) {
        // Mode tambah data
        success = await apiService.addWisata(data);
        message = success ? 'Data wisata berhasil ditambahkan!' : 'Gagal menambahkan data wisata.';
      } else {
        // Mode edit data
        data['id'] = widget.wisata!['id']; // ID wajib untuk edit
        success = await apiService.editWisata(data);
        message = success ? 'Data wisata berhasil diupdate!' : 'Gagal mengupdate data wisata.';
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        Navigator.pop(context, true); // Kembali ke Home screen dan refresh
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _fotoController.dispose();
    _kategoriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wisata == null ? 'Tambah Wisata Baru' : 'Edit Wisata'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Wisata',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.place_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama wisata wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _lokasiController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _deskripsiController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _fotoController,
                      decoration: const InputDecoration(
                        labelText: 'URL Foto (Opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image_outlined),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _kategoriController,
                      decoration: const InputDecoration(
                        labelText: 'Kategori (Opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton.icon(
                      onPressed: _saveData,
                      icon: const Icon(Icons.save),
                      label: Text(widget.wisata == null ? 'Simpan Data' : 'Update Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}