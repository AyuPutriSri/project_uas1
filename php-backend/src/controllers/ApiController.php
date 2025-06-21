<?php

namespace App\Controllers;

use App\Services\UserService;

class ApiController
{
    private $userService;

    public function __construct()
    {
        $this->userService = new UserService();
    }

    public function getUsers()
    {
        $users = $this->userService->fetchAllUsers();
        echo json_encode($users);
    }

    public function createUser($data)
    {
        $user = $this->userService->addUser($data);
        echo json_encode($user);
    }

    public function updateUser($id, $data)
    {
        $user = $this->userService->updateUser($id, $data);
        echo json_encode($user);
    }

    public function deleteUser($id)
    {
        $result = $this->userService->removeUser($id);
        echo json_encode(['success' => $result]);
    }
}