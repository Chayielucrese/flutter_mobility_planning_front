import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ActivationPage extends StatefulWidget {
  @override
  _ActivationPageState createState() => _ActivationPageState();
}

Map<String, int>? roles;

const url = 'http://192.168.137.1:9000/api';

class _ActivationPageState extends State<ActivationPage> {
  final List<TextEditingController> _controllers =
      List.generate(5, (index) => TextEditingController());

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<String> _getUserEmail() async {
    Map<String, String> userParams = await _getUserParams();
    return userParams['email'] ?? 'Unknown';
  }

  Future<String> _getUserRole() async {
    Map<String, String> userParams = await _getUserParams();
    return userParams['role'] ?? 'Unknown';
  }

  Future<http.Response> _activateAccount(String code, String email) async {
    final response = await http.put(
      Uri.parse("${url}/activateAccount"),
      body: {
        "code_send": code,
        "email": email,
        "role": await _getUserRole(),
      },
    );
    return response;
  }

  void _validateCode() async {
    print("Starting _validateCode"); // Debugging statement

    // Collecting code from text controllers
    String code = _controllers.map((controller) => controller.text).join();
    print("Collected code: $code"); // Debugging statement
    String? email = await _getUserEmail();

    print("Retrieved email: $email"); // Debugging statement

    // Debugging statements
    print("Code: $code");
    print("Email: $email");

    if (email != null && code.length == 5) {
      print("Validating code and email..."); // Debugging statement
      final res = await _activateAccount(code, email);
      print("Response received"); // Debugging statement

      if (res.statusCode == 200) {
        // Handle successful activation
        print('Activation successful');
        final responseJson = json.decode(res.body);

        print('${responseJson['token']['token']}, activation token');
        await _getAllRoles();
        String? userRole = await _getUserRole();

        roles?.forEach((name, id) async {
          if (name == "client" && int.parse(userRole) == id) {
            print("${userRole}, hii");
            Navigator.pushNamed(context, '/client');
          } else if (name == "driver" && int.parse(userRole) == id) {
            _setToken(responseJson['token']['token']);
            Navigator.pushNamed(context, '/driver');
          }
        });
      } else {
        print("Activation failed with status code: ${res.statusCode}");
        final errorResponse = json.decode(res.body);
        print("Invalid code: ${res.body}, code: ${code}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${errorResponse['msg']}",
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: Colors.pink,
          ),
        );
      }
    } else {
      // Show an error message
      print('Invalid code or email');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid code or email',
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: Colors.pink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54.withOpacity(0.8),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Activate Your Account',
          style: TextStyle(color: Colors.pink),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'Assets/map.png', // Update with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: Colors.black54
                  .withOpacity(0.8), // Semi-transparent black overlay
            ),
          ),
          // Content on top of the overlay
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter the code sent to your email',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  SizedBox(height: 20.0),
                  // Row with 5 code boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0), // Space between boxes
                        child: _buildCodeBox(index),
                      );
                    }),
                  ),
                  SizedBox(height: 20.0),

                  ElevatedButton(
                    onPressed: _validateCode,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 60.0, vertical: 10.0),
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Validate',
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBox(int index) {
    return SizedBox(
      width: 40.0,
      height: 40.0,
      child: TextField(
        controller: _controllers[index],
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          // White background for each box
          border: OutlineInputBorder(
            borderSide: BorderSide.none, // Remove the border
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 4) {
            FocusScope.of(context).nextFocus(); // Move to the next field
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context)
                .previousFocus(); // Move to the previous field
          }
        },
      ),
    );
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

  Future<void> _setToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString("token", token);
  }

  Future<Object?> _getAllRoles() async {
    try {
      final res = await _role();
      print("Raw response body: ${res.body}");
      if (res.statusCode == 200) {
        Map<String, dynamic> response = json.decode(res.body);
        List<dynamic> rolesList = response['success'];

        setState(() {
          roles = {for (var role in rolesList) role['name']: role['id']};
        });
      } else {
        print("fail to get role: ${res.statusCode}");
      }
    } catch (e) {
      print("Error occurred while fetching roles: $e");
    }
    return null;
  }

  Future<http.Response> _role() async {
    final response = await http.get(Uri.parse("$url/getRoles"));
    return response;
  }
}
