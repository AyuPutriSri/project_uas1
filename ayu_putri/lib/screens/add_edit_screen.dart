// filepath: ayu_putri/lib/screens/add_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import ini
import 'dart:io'; // Import ini untuk File
import '../services/api_service.dart';

class AddEditScreen extends StatefulWidget {
  final Map<String, dynamic>? wisata;

  const AddEditScreen({Key? key, this.wisata}) : super(key: key);

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  // _fotoController tidak lagi digunakan untuk URL, tapi mungkin untuk menampilkan URL yang sudah ada
  final TextEditingController _kategoriController = TextEditingController();

  ApiService apiService = ApiService();
  bool _isLoading = false;

  XFile? _pickedImage; // Untuk menyimpan file gambar yang dipilih
  String? _existingImageUrl; // Untuk menyimpan URL foto yang sudah ada (saat edit)

  @override
  void initState() {
    super.initState();
    if (widget.wisata != null) {
      _namaController.text = widget.wisata!['nama'] ?? '';
      _lokasiController.text = widget.wisata!['lokasi'] ?? '';
      _deskripsiController.text = widget.wisata!['deskripsi'] ?? '';
      _kategoriController.text = widget.wisata!['kategori'] ?? '';
      _existingImageUrl = widget.wisata!['foto']; // Ambil URL foto yang sudah ada
    }
  }

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery); // Pilih dari galeri
    setState(() {
      _pickedImage = image;
      _existingImageUrl = null; // Hapus URL yang sudah ada jika gambar baru dipilih
    });
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, String> data = {
        'nama': _namaController.text,
        'lokasi': _lokasiController.text,
        'deskripsi': _deskripsiController.text,
        'kategori': _kategoriController.text,
      };

      // Tambahkan ID jika ini mode edit
      if (widget.wisata != null) {
        data['id'] = widget.wisata!['id'].toString();
      }

      bool success;
      String message = '';

      if (widget.wisata == null) {
        // Mode tambah data
        success = await apiService.addWisata(data, _pickedImage); // Kirim file juga
        message = success ? 'Data wisata berhasil ditambahkan!' : 'Gagal menambahkan data wisata.';
      } else {
        // Mode edit data
        success = await apiService.editWisata(data, _pickedImage); // Kirim file juga
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
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
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
                    // Bagian untuk memilih dan menampilkan gambar
                    _pickedImage != null
                        ? Image.file(
                            File(_pickedImage!.path),
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                            ? Image.network(
                                _existingImageUrl!,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 80),
                                ),
                              )
                            : Container(),
                    const SizedBox(height: 8.0),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text('Pilih Foto (Opsional)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        textStyle: const TextStyle(fontSize: 16),
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