import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Data user bisa diambil dari provider/shared preferences
    return Scaffold(
      appBar: AppBar(title: Text('Profil User')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 100),
            SizedBox(height: 16),
            Text('admin1', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('adminayu@email.com'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}