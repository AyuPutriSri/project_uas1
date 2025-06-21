<?php
header('Content-Type: application/json');
require_once __DIR__ . '/../config/database.php';

$stmt = $pdo->query("SELECT * FROM wisata ORDER BY id DESC");
$data = $stmt->fetchAll();
echo json_encode($data);