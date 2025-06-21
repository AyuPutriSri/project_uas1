<?php
header('Content-Type: application/json');
require_once __DIR__ . '/../config/database.php';

$data = json_decode(file_get_contents('php://input'), true);

if (!$data) {
    echo json_encode(['success' => false, 'message' => 'Data tidak lengkap']);
    exit;
}

try {
    $stmt = $pdo->prepare("INSERT INTO wisata (nama, lokasi, deskripsi, foto, kategori) VALUES (:nama, :lokasi, :deskripsi, :foto, :kategori)");
    $stmt->execute([
        ':nama' => $data['nama'],
        ':lokasi' => $data['lokasi'],
        ':deskripsi' => $data['deskripsi'],
        ':foto' => $data['foto'],
        ':kategori' => $data['kategori'],
    ]);
    echo json_encode(['success' => true]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}