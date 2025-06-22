<?php
// filepath: php-backend/public/get_wisata.php

ini_set('display_errors', 1); // Tambahkan ini untuk debugging
ini_set('display_startup_errors', 1); // Tambahkan ini
error_reporting(E_ALL); // Tambahkan ini

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS"); // Tambahkan OPTIONS
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// *** PENTING: Tangani Preflight Request (OPTIONS) ***
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Sertakan file database
require_once __DIR__ . '/../config/database.php'; // Menggunakan require_once

// Inisialisasi objek Database dan dapatkan koneksi
$database = new Database();
$db = $database->getConnection(); // <-- PENTING: Pastikan baris ini ada

try {
    $query = "SELECT id, nama, lokasi, deskripsi, foto, kategori FROM wisata ORDER BY id DESC";
    $stmt = $db->prepare($query); // Gunakan $db yang sudah diinisialisasi
    $stmt->execute();

    $wisata_arr = array();
    $wisata_arr["records"] = array();

    if ($stmt->rowCount() > 0) {
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            // Memastikan semua kunci ada sebelum mengaksesnya
            $id = $row['id'] ?? null;
            $nama = $row['nama'] ?? null;
            $lokasi = $row['lokasi'] ?? null;
            $deskripsi = $row['deskripsi'] ?? null;
            $foto = $row['foto'] ?? null;
            $kategori = $row['kategori'] ?? null;
            
            $wisata_item = array(
                "id" => $id,
                "nama" => $nama,
                "lokasi" => $lokasi,
                "deskripsi" => $deskripsi ? html_entity_decode($deskripsi) : null, // Dekode HTML jika ada
                "foto" => $foto,
                "kategori" => $kategori
            );
            array_push($wisata_arr["records"], $wisata_item);
        }
        http_response_code(200); // OK
        echo json_encode($wisata_arr);
    } else {
        http_response_code(200); // Ubah ke 200, bukan 404, jika tidak ada data tapi query berhasil
        echo json_encode(array("message" => "Tidak ada data wisata ditemukan.", "records" => [])); // Kirim array kosong
    }
} catch (PDOException $e) {
    http_response_code(500); // Internal Server Error
    echo json_encode(array("message" => "Terjadi kesalahan database: " . $e->getMessage()));
} catch (Exception $e) { // Tangkap exception umum lainnya
    http_response_code(500);
    echo json_encode(array("message" => "Terjadi kesalahan server: " . $e->getMessage()));
}
?>