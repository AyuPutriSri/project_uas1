<?php
// Set header untuk mengizinkan CORS dan JSON response
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Sertakan file database
include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

try {
    $query = "SELECT id, nama, lokasi, deskripsi, foto, kategori FROM wisata ORDER BY id DESC";
    $stmt = $db->prepare($query);
    $stmt->execute();

    $wisata_arr = array();
    $wisata_arr["records"] = array();

    if ($stmt->rowCount() > 0) {
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row); // membuat $id, $nama, dst dari baris
            $wisata_item = array(
                "id" => $id,
                "nama" => $nama,
                "lokasi" => $lokasi,
                "deskripsi" => html_entity_decode($deskripsi),
                "foto" => $foto,
                "kategori" => $kategori
            );
            array_push($wisata_arr["records"], $wisata_item);
        }
        http_response_code(200); // OK
        echo json_encode($wisata_arr);
    } else {
        http_response_code(404); // Not Found
        echo json_encode(array("message" => "Tidak ada data wisata ditemukan."));
    }
} catch (PDOException $e) {
    http_response_code(500); // Internal Server Error
    echo json_encode(array("message" => "Terjadi kesalahan database: " . $e->getMessage()));
}
?>