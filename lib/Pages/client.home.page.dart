import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ClientHomePage extends StatefulWidget {
  @override
  _ClientHomePageState createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      child:Scaffold(
      appBar: AppBar(
        title: Text(
          'Client Home Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pink,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.pink),
              title: Text('Profile', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Profile page
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet, color: Colors.pink),
              title: Text('Wallet', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Wallet page
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.pink),
              title: Text('Logout', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pushNamed(context, '/');
                // Perform logout action
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to the Client Home Page!',
          style: TextStyle(fontSize: 24, color: Colors.pink),
        ),
      ),
    ),
    );
  }
}