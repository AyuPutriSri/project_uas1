<?php
// filepath: php-backend/public/edit_wisata.php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, PUT, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

// Ambil data dari $_POST karena ini adalah multipart/form-data
$id = $_POST['id'] ?? '';
$nama = $_POST['nama'] ?? '';
$lokasi = $_POST['lokasi'] ?? '';
$deskripsi = $_POST['deskripsi'] ?? '';
$kategori = $_POST['kategori'] ?? null;
$current_foto_url = $_POST['foto_url_lama'] ?? null; // Ambil URL foto yang lama jika tidak ada unggahan baru

$foto_url = $current_foto_url; // Default ke URL foto lama
$upload_dir = 'uploads/'; // Subfolder tempat menyimpan gambar di dalam public/
$base_url_for_files = 'http://localhost:8000/uploads/'; // URL untuk akses file dari browser

// Periksa apakah ada file foto baru yang diunggah
if (isset($_FILES['foto']) && $_FILES['foto']['error'] == UPLOAD_ERR_OK) {
    $file_tmp_name = $_FILES['foto']['tmp_name'];
    $file_name = uniqid() . '_' . basename($_FILES['foto']['name']); // Nama file unik
    $target_file = $upload_dir . $file_name;

    // Pastikan folder uploads ada
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }

    // Pindahkan file baru
    if (move_uploaded_file($file_tmp_name, $target_file)) {
        $foto_url = $base_url_for_files . $file_name;

        // Opsional: Hapus foto lama jika ada dan berbeda dari yang baru
        if ($current_foto_url && strpos($current_foto_url, $base_url_for_files) !== false) {
            $old_file_name = basename($current_foto_url);
            $old_file_path = $upload_dir . $old_file_name;
            if (file_exists($old_file_path) && $old_file_path !== $target_file) {
                unlink($old_file_path); // Hapus file lama
            }
        }
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Gagal mengunggah foto baru.", "success" => false));
        exit();
    }
}

// Pastikan data teks yang wajib diisi tidak kosong
if (!empty($id) && !empty($nama) && !empty($lokasi) && !empty($deskripsi)) {
    try {
        $query = "UPDATE wisata SET nama = :nama, lokasi = :lokasi, deskripsi = :deskripsi, foto = :foto, kategori = :kategori WHERE id = :id";
        $stmt = $db->prepare($query);

        $stmt->bindParam(":nama", $nama);
        $stmt->bindParam(":lokasi", $lokasi);
        $stmt->bindParam(":deskripsi", $deskripsi);
        $stmt->bindParam(":foto", $foto_url); // Update URL foto
        $stmt->bindParam(":kategori", $kategori);
        $stmt->bindParam(":id", $id);

        if ($stmt->execute()) {
            if ($stmt->rowCount() > 0) {
                http_response_code(200);
                echo json_encode(array("message" => "Data wisata berhasil diupdate.", "success" => true));
            } else {
                http_response_code(200);
                echo json_encode(array("message" => "Tidak ada perubahan pada data wisata atau ID tidak ditemukan.", "success" => true));
            }
        } else {
            http_response_code(503);
            echo json_encode(array("message" => "Gagal mengupdate data wisata.", "success" => false));
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(array("message" => "Terjadi kesalahan database: " . $e->getMessage(), "success" => false));
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(array("message" => "Terjadi kesalahan: " . $e->getMessage(), "success" => false));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Data tidak lengkap. ID, nama, lokasi, dan deskripsi wajib diisi.", "success" => false));
}
?>