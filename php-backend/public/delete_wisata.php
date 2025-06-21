<?php
// filepath: php-backend/public/delete_wisata.php

ini_set('display_errors', 1); // Tambahkan ini untuk debugging
ini_set('display_startup_errors', 1); // Tambahkan ini
error_reporting(E_ALL); // Tambahkan ini

// Set header untuk mengizinkan CORS dan JSON response
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, DELETE, OPTIONS"); // *** PENTING: Tambahkan OPTIONS di sini ***
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// *** PENTING: Tangani Preflight Request (OPTIONS) ***
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200); // Respon dengan OK
    exit(); // Hentikan eksekusi script setelah mengirim header
}

// Sertakan file database
require_once __DIR__ . '/../config/database.php';

// Inisialisasi objek Database dan dapatkan koneksi
$database = new Database();
$db = $database->getConnection();

// Ambil data POST (Flutter menggunakan POST untuk delete)
$data = json_decode(file_get_contents("php://input"), true); // Tambahkan 'true' untuk mendapatkan array asosiatif

// Pastikan ID ada
if (!empty($data['id'])) {
    $id = $data['id'];

    try {
        // Query untuk delete data
        $query = "DELETE FROM wisata WHERE id = :id";
        $stmt = $db->prepare($query);

        // Bind parameter
        $stmt->bindParam(":id", $id);

        if ($stmt->execute()) {
            if ($stmt->rowCount() > 0) {
                http_response_code(200); // OK
                echo json_encode(array("message" => "Data wisata berhasil dihapus.", "success" => true));
            } else {
                http_response_code(404); // Not Found jika ID tidak ada
                echo json_encode(array("message" => "Data wisata tidak ditemukan.", "success" => false));
            }
        } else {
            http_response_code(503); // Service Unavailable
            echo json_encode(array("message" => "Gagal menghapus data wisata.", "success" => false));
        }
    } catch (PDOException $e) {
        http_response_code(500); // Internal Server Error
        echo json_encode(array("message" => "Terjadi kesalahan database: " . $e->getMessage(), "success" => false));
    } catch (Exception $e) {
        http_response_code(500); // Internal Server Error
        echo json_encode(array("message" => "Terjadi kesalahan: " . $e->getMessage(), "success" => false));
    }
} else {
    http_response_code(400); // Bad Request
    echo json_encode(array("message" => "ID tidak ditemukan.", "success" => false));
}
?>