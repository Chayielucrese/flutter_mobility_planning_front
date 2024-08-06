import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationConfirmationPage extends StatelessWidget {
  Future<Map<String, String>> _getUserParams() async {
    final pref = await SharedPreferences.getInstance();
    String? jsonString = pref.getString('userAttributes');
    if (jsonString != null) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return jsonMap.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }

  Future<String> _getUserName() async {
    Map<String, String> userParams = await _getUserParams();
    return userParams['name'] ?? 'Unknown';
  }



  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to dismiss the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Exit Confirmation', style: TextStyle(color: Colors.pink, fontSize: 20),),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to quit this page?', style: TextStyle(color: Colors.black),),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.pink),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Quit', style: TextStyle(color: Colors.pink),),
              onPressed: () {
                Navigator.of(context).pushNamed('/');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.9),
        appBar: AppBar(
          title: Text('Registration Confirmation',
              style: TextStyle(color: Colors.white, fontSize: 20)),
          backgroundColor: Colors.pink,
          automaticallyImplyLeading: false, // This removes the back arrow
        ),
        body: FutureBuilder<Map<String, String>>(
          future: _getUserParams(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink)));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading user data'));
            } else {
              final userParams = snapshot.data!;
              final userName = userParams['name']?.toUpperCase() ?? 'UNKNOWN';
              final userSurname =
                  userParams['surname']?.toUpperCase() ?? 'UNKNOWN';

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Image.asset(
                        'Assets/driver.png',
                        width: 200,
                        height: 130,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "YOU ARE ALMOST THERE, $userName $userSurname",
                      style: TextStyle(
                          color: Colors.pink,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Thank you for registering with us. Your documents are currently being verified. We will get back to you soon via email with further details.",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        _showExitConfirmationDialog(context);
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical: 10.0), // Background color
                        side: BorderSide(color: Colors.pink), // Border color
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
