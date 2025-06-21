# PHP Backend for Flutter Application

## Overview
This project is a PHP backend designed to serve as a REST API for a Flutter application. It provides endpoints for user management, including creating, retrieving, updating, and deleting users.

## Project Structure
```
php-backend
├── public
│   └── index.php
├── src
│   ├── controllers
│   │   └── ApiController.php
│   ├── models
│   │   └── User.php
│   ├── routes
│   │   └── api.php
│   └── services
│       └── UserService.php
├── config
│   └── database.php
├── composer.json
└── README.md
```

## Setup Instructions

1. **Clone the Repository**
   ```
   git clone <repository-url>
   cd php-backend
   ```

2. **Install Dependencies**
   Make sure you have Composer installed. Run the following command to install the required dependencies:
   ```
   composer install
   ```

3. **Configure Database**
   Update the `config/database.php` file with your database connection settings:
   ```php
   $host = 'your_host';
   $username = 'your_username';
   $password = 'your_password';
   $database = 'your_database';
   ```

4. **Run the Application**
   You can use the built-in PHP server to run the application:
   ```
   php -S localhost:8000 -t public
   ```

5. **Access the API**
   The API endpoints can be accessed at `http://localhost:8000/api/`. Refer to the API documentation below for available endpoints.

## API Usage Examples

- **Get Users**
  - **Endpoint:** `GET /api/users`
  - **Description:** Retrieves a list of users.

- **Create User**
  - **Endpoint:** `POST /api/users`
  - **Description:** Creates a new user. Requires JSON payload with user details.

- **Update User**
  - **Endpoint:** `PUT /api/users/{id}`
  - **Description:** Updates an existing user. Requires JSON payload with updated user details.

- **Delete User**
  - **Endpoint:** `DELETE /api/users/{id}`
  - **Description:** Deletes a user by ID.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.