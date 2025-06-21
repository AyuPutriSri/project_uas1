<?php
// Set header untuk mengizinkan CORS dan JSON response
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Sertakan file database
include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

// Ambil data POST
$data = json_decode(file_get_contents("php://input"));

// Pastikan data tidak kosong
if (!empty($data->nama) && !empty($data->lokasi) && !empty($data->deskripsi)) {
    $nama = $data->nama;
    $lokasi = $data->lokasi;
    $deskripsi = $data->deskripsi;
    $foto = isset($data->foto) ? $data->foto : null; // Foto bisa opsional
    $kategori = isset($data->kategori) ? $data->kategori : null; // Kategori bisa opsional

    try {
        // Query untuk insert data
        $query = "INSERT INTO wisata (nama, lokasi, deskripsi, foto, kategori) VALUES (:nama, :lokasi, :deskripsi, :foto, :kategori)";
        $stmt = $db->prepare($query);

        // Bind parameter
        $stmt->bindParam(":nama", $nama);
        $stmt->bindParam(":lokasi", $lokasi);
        $stmt->bindParam(":deskripsi", $deskripsi);
        $stmt->bindParam(":foto", $foto);
        $stmt->bindParam(":kategori", $kategori);

        if ($stmt->execute()) {
            http_response_code(201); // Created
            echo json_encode(array("message" => "Data wisata berhasil ditambahkan.", "success" => true));
        } else {
            http_response_code(503); // Service Unavailable
            echo json_encode(array("message" => "Gagal menambahkan data wisata.", "success" => false));
        }
    } catch (PDOException $e) {
        http_response_code(500); // Internal Server Error
        echo json_encode(array("message" => "Terjadi kesalahan database: " . $e->getMessage(), "success" => false));
    }
} else {
    http_response_code(400); // Bad Request
    echo json_encode(array("message" => "Data tidak lengkap. Nama, lokasi, dan deskripsi wajib diisi.", "success" => false));
}
?>