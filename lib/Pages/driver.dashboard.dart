import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverDashboardPage extends StatelessWidget {
  Future<String> _getUserName() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString('userName') ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _getUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error');
            } else {
              final userName = snapshot.data ?? 'User';
              return Text('Hello $userName');
            }
          },
        ),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: Text(
          'Driver Dashboard Content Here',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}
