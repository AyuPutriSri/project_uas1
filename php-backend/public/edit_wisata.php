<?php
header('Content-Type: application/json');
require_once '../config/database.php';

$method = $_SERVER['REQUEST_METHOD'];
if ($method !== 'PUT' && $method !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

$id = $input['id'] ?? null;
$nama = $input['nama'] ?? null;
$lokasi = $input['lokasi'] ?? null;
$deskripsi = $input['deskripsi'] ?? null;
$foto = $input['foto'] ?? null;
$kategori = $input['kategori'] ?? null;

if (!$id || !$nama || !$lokasi || !$deskripsi) {
    http_response_code(400);
    echo json_encode(['error' => 'Incomplete data']);
    exit;
}

$stmt = $pdo->prepare("UPDATE wisata SET nama=?, lokasi=?, deskripsi=?, foto=?, kategori=? WHERE id=?");
if ($stmt->execute([$nama, $lokasi, $deskripsi, $foto, $kategori, $id])) {
    echo json_encode(['success' => true]);
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to update data']);
}