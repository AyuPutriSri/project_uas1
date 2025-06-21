<?php

namespace App\Services;

use App\Models\User;

class UserService
{
    public function fetchAllUsers()
    {
        return User::all();
    }

    public function addUser(array $data)
    {
        $user = new User();
        $user->name = $data['name'];
        $user->email = $data['email'];
        return $user->save();
    }

    public function removeUser($id)
    {
        $user = User::find($id);
        if ($user) {
            return $user->delete();
        }
        return false;
    }
}