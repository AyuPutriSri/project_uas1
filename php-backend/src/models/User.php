<?php

class User {
    private $id;
    private $name;
    private $email;

    public function __construct($name, $email, $id = null) {
        $this->name = $name;
        $this->email = $email;
        $this->id = $id;
    }

    public function getId() {
        return $this->id;
    }

    public function getName() {
        return $this->name;
    }

    public function getEmail() {
        return $this->email;
    }

    public function save() {
        // Logic to save the user to the database
    }

    public function delete() {
        // Logic to delete the user from the database
    }
}