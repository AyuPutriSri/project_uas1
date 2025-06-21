<?php
class Database {
    private $host = "localhost"; // Sesuaikan jika host database berbeda
    private $db_name = "db_wisata"; // Nama database Anda
    private $username = "root"; // Username database Anda
    private $password = ""; // Password database Anda (kosong jika tidak ada)
    public $conn;

    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new PDO("mysql:host=" . $this->host . ";dbname=" . $this->db_name, $this->username, $this->password);
            $this->conn->exec("set names utf8");
        } catch(PDOException $exception) {
            http_response_code(500); // Internal Server Error
            echo json_encode(array("message" => "Connection error: " . $exception->getMessage()));
            exit(); // Hentikan eksekusi script
        }
        return $this->conn;
    }
}
?>