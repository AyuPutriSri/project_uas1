<?php
// Set header untuk mengizinkan CORS dan JSON response
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, PUT"); // Mengizinkan POST dan PUT
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Sertakan file database
include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

// Ambil data POST
$data = json_decode(file_get_contents("php://input"));

// Pastikan data tidak kosong dan ID ada
if (!empty($data->id) && !empty($data->nama) && !empty($data->lokasi) && !empty($data->deskripsi)) {
    $id = $data->id;
    $nama = $data->nama;
    $lokasi = $data->lokasi;
    $deskripsi = $data->deskripsi;
    $foto = isset($data->foto) ? $data->foto : null; // Foto bisa opsional
    $kategori = isset($data->kategori) ? $data->kategori : null; // Kategori bisa opsional

    try {
        // Query untuk update data
        $query = "UPDATE wisata SET nama = :nama, lokasi = :lokasi, deskripsi = :deskripsi, foto = :foto, kategori = :kategori WHERE id = :id";
        $stmt = $db->prepare($query);

        // Bind parameter
        $stmt->bindParam(":nama", $nama);
        $stmt->bindParam(":lokasi", $lokasi);
        $stmt->bindParam(":deskripsi", $deskripsi);
        $stmt->bindParam(":foto", $foto);
        $stmt->bindParam(":kategori", $kategori);
        $stmt->bindParam(":id", $id);

        if ($stmt->execute()) {
            // Periksa apakah ada baris yang terpengaruh (data benar-benar diupdate)
            if ($stmt->rowCount() > 0) {
                http_response_code(200); // OK
                echo json_encode(array("message" => "Data wisata berhasil diupdate.", "success" => true));
            } else {
                // Jika rowCount 0, berarti ID tidak ditemukan atau data tidak berubah
                http_response_code(200); // OK, tapi dengan pesan bahwa tidak ada perubahan
                echo json_encode(array("message" => "Tidak ada perubahan pada data wisata atau ID tidak ditemukan.", "success" => true));
            }
        } else {
            http_response_code(503); // Service Unavailable
            echo json_encode(array("message" => "Gagal mengupdate data wisata.", "success" => false));
        }
    } catch (PDOException $e) {
        http_response_code(500); // Internal Server Error
        echo json_encode(array("message" => "Terjadi kesalahan database: " . $e->getMessage(), "success" => false));
    }
} else {
    http_response_code(400); // Bad Request
    echo json_encode(array("message" => "Data tidak lengkap. ID, nama, lokasi, dan deskripsi wajib diisi.", "success" => false));
}
?>