<?php
// filepath: php-backend/public/add_wisata.php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Max-Age: 3600");
// Tambahkan 'Content-Disposition' jika Anda ingin memungkinkan pengiriman file langsung.
// Tapi untuk multipart/form-data, ini tidak selalu perlu di header ACL.
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");


if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

// Ambil data dari $_POST karena ini adalah multipart/form-data
// json_decode(file_get_contents("php://input"), true) TIDAK AKAN BEKERJA UNTUK multipart/form-data
$nama = $_POST['nama'] ?? '';
$lokasi = $_POST['lokasi'] ?? '';
$deskripsi = $_POST['deskripsi'] ?? '';
$kategori = $_POST['kategori'] ?? null;

$foto_url = null; // Default null
$upload_dir = 'uploads/'; // Subfolder tempat menyimpan gambar di dalam public/
$base_url_for_files = 'http://localhost:8000/uploads/'; // URL untuk akses file dari browser

// Periksa apakah ada file foto yang diunggah
if (isset($_FILES['foto']) && $_FILES['foto']['error'] == UPLOAD_ERR_OK) {
    $file_tmp_name = $_FILES['foto']['tmp_name'];
    $file_name = uniqid() . '_' . basename($_FILES['foto']['name']); // Nama file unik
    $target_file = $upload_dir . $file_name;

    // Pastikan folder uploads ada
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }

    // Pindahkan file ke folder tujuan
    if (move_uploaded_file($file_tmp_name, $target_file)) {
        $foto_url = $base_url_for_files . $file_name; // Simpan URL publik
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Gagal mengunggah foto.", "success" => false));
        exit();
    }
}

// Pastikan data teks yang wajib diisi tidak kosong
if (!empty($nama) && !empty($lokasi) && !empty($deskripsi)) {
    try {
        $query = "INSERT INTO wisata (nama, lokasi, deskripsi, foto, kategori) VALUES (:nama, :lokasi, :deskripsi, :foto, :kategori)";
        $stmt = $db->prepare($query);

        $stmt->bindParam(":nama", $nama);
        $stmt->bindParam(":lokasi", $lokasi);
        $stmt->bindParam(":deskripsi", $deskripsi);
        $stmt->bindParam(":foto", $foto_url); // Simpan URL foto
        $stmt->bindParam(":kategori", $kategori);

        if ($stmt->execute()) {
            http_response_code(201);
            echo json_encode(array("message" => "Data wisata berhasil ditambahkan.", "success" => true, "id" => $db->lastInsertId()));
        } else {
            http_response_code(503);
            echo json_encode(array("message" => "Gagal menambahkan data wisata.", "success" => false));
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
    echo json_encode(array("message" => "Data tidak lengkap. Nama, lokasi, dan deskripsi wajib diisi.", "success" => false));
}
?>