import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}
Future<Map<String, String>> _getUserParams() async {
  final pref = await SharedPreferences.getInstance();
  String? jsonString = pref.getString('userAttributes');
  if (jsonString != null) {
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }
  return {};
}

Future<String> _getUserSurName() async {
  Map<String, String> userParams = await _getUserParams();
  return userParams['surname'] ?? 'Unknown';
}


class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  bool _visible = false;
  late AnimationController _animationController;
  late Animation<double> _textAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..forward();

    _textAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _visible = true;
      });
    });

    // Navigate to DriverDashboardPage after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverDashboardPage()), // Update with the correct path to your dashboard
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('Assets/taxman.jpg'), // Background image
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.7), // Dark overlay
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                SizedBox(height: 20),
                FadeTransition(
                  opacity: _opacityAnimation,
                ),
                SizedBox(height: 50),
                Text(
                  'Dashboard Loading......',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                CircularProgressIndicator(
                  color: Colors.pink,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DriverDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0), // Set the height here
        child: AppBar(
          automaticallyImplyLeading: false, // Remove the back arrow
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String>(
                future: _getUserSurName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  } else if (snapshot.hasError) {
                    return Text('Error');
                  } else {
                    final userName = snapshot.data ?? 'User';
                    return Text(
                      'Hello $userName',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 8), // Space between name and message
              Text(
                'You cannot receive requests until your documents are verified.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
                overflow: TextOverflow.ellipsis, // Handle overflow
              ),
            ],
          ),
          backgroundColor: Colors.white,
          centerTitle: false, // Align the title to the start
          toolbarHeight: 120.0, // Height of the AppBar
        ),
      ),
      body: Center(
        child: Text(
          'Driver Dashboard Content Here',
          style: TextStyle(fontSize: 24, color: Colors.pink),
        ),
      ),
    ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WelcomePage(),
  ));
}
