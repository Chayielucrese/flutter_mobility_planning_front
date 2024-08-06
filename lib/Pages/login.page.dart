import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart' as validator;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<http.Response> _loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse("${url}/userLogin"),
      body: {
        "email": email,
        "password": password,
      },
    );
    return response;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      try {
        final response = await _loginUser(email, password);
        if (response.statusCode == 200 || response.statusCode == 201) {
          print("User created successfully.");
          final responseJson = json.decode(response.body);
          _loginToken(responseJson['token']['token']);
          await _getAllRoles();
          String? userRole = await _getUserRole();

          roles?.forEach((name, id) async {
            if (name == "client" && int.parse(userRole) == id) {
              Navigator.pushNamed(context, '/client');
            } else if (name == "driver" && int.parse(userRole) == id) {
              Navigator.pushNamed(context, '/client');
            }
          });
          _formKey.currentState!.reset();
        } else {
          final errorResponse = json.decode(response.body);
          print("Registration failed: ${errorResponse['msg']}");
          print(response.body);
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
      } catch (e) {
        print("Error occurred during registration: $e");
      }
      // Handle the response, e.g., navigate to another screen, show an error, etc.
    }
  }

  Future<String> _getUserRole() async {
    Map<String, String> userParams = await _getUserParams();
    return userParams['role'] ?? 'Unknown';
  }

  Map<String, int>? roles;

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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: ((didpop) {
        if (didpop) {
          return;
        }
        Navigator.pushNamed(context, '/');
      }),
      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'Assets/taxi.jpg', // Update with your image path
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
            // Centered content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header with app name and login text
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Text(
                          'eTravel',
                          style: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Form section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Container(
                          width: 320.0,
                          height: 290.0, // Adjust height as needed
                          padding: EdgeInsets.all(20.0),
                          margin: EdgeInsets.symmetric(
                              vertical:
                                  28.0), // Margin to space out from header
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.black54, width: 1.0),
                            borderRadius:
                                BorderRadius.circular(10.0), // Rounded corners
                            color: Colors.white.withOpacity(
                                0.9), // Semi-transparent white background
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                labelText: 'Email',
                                icon: Icons.email,
                                controller: _emailController,
                                isEmail: true,
                              ),
                              SizedBox(height: 10.0),
                              _buildTextField(
                                labelText: 'Password',
                                obscureText: true,
                                icon: Icons.lock,
                                controller: _passwordController,
                              ),
                              SizedBox(height: 20.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: _submitForm,
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black54),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 40.0, vertical: 10.0),
                                      backgroundColor: Colors.pink,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Rounded corners
                                      ),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                          fontSize: 20.0, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/signup');
                                      },
                                      child: Text(
                                        'Already have an account?',
                                        style: TextStyle(
                                            fontSize: 16.0, color: Colors.pink),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    bool obscureText = false,
    required IconData icon,
    required TextEditingController controller,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 1,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black54),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        prefixIcon: Icon(icon, color: Colors.black),
        labelStyle: TextStyle(color: Colors.black),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black54),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black54),
        ),
      ),
      obscureText: obscureText,
      style: TextStyle(color: Colors.black),
      textAlignVertical: TextAlignVertical.center,
      validator: (value) {
        value = value?.trim();
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (isEmail && !validator.isEmail(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Future<void> _loginToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString("token", token);
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
}

const url = 'http://192.168.137.1:9000/api';
