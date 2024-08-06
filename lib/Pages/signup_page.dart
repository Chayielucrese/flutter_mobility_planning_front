import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:validators/validators.dart' as validator;
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

const url = 'http://192.168.137.1:9000/api';
const List<String> cameroonCities = [
  'Douala',
  'Yaoundé',
  'Garoua',
  'Kousseri',
  'Bamenda',
  'Maroua',
  'Nkongsamba',
  'Bafoussam',
  'Ngaoundéré',
  'Bertoua',
  'Loum',
  'Kumba',
  'Edéa',
  'Foumban',
  'Mbouda',
  'Dschang',
  'Limbé',
  'Ebolowa',
  'Kumbo',
  'Guider',
  'Mbalmayo',
  'Bafia',
  'Wum',
  'Tiko',
  'Buea',
  'Kribi',
  'Sangmélima',
  'Meiganga',
  'Yagoua',
  'Mokolo'
];

class _SignUpPageState extends State<SignUpPage> {
  bool isDriver = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Map<String, int>? roles;

  @override
  void initState() {
    super.initState();
    _getAllRoles();
  }

  //get all roles
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Capture values from controllers
      String name = _nameController.text;
      String surname = _surnameController.text;
      String email = _emailController.text.trim();
      String phone = _phoneController.text;
      String password = _passwordController.text;
      String city = _cityController.text;
      int role = 0;

      roles?.forEach((name, id) {
        if (name == "client") {
          role = id;
        } else if (name == "driver" && isDriver) {
          role = id;
        }
      });

      // Debug print statements
      print("Name: $name");
      print("Surname: $surname");
      print("Email: $email");
      print("Phone: $phone");
      print("Password: $password");
      print("City: $city");
      print("role: $role");

      try {
        final response = await _createUser(
            name, surname, email, password, phone, city, role);
        if (response.statusCode == 201) {
          print("User created successfully.");

          final errorResponse = json.decode(response.body);
          print("Registration failed: ${errorResponse['msg']}");
          print(response.body);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("email", email);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${errorResponse['msg']}",
                style: TextStyle(fontSize: 18),
              ),
              backgroundColor: Colors.pink,
            ),
          );
          _setUserParams(
              name, surname, role.toString(), email, password, city, phone);

          _setEmail(email);
          print("email, ${email}, ${phone}");

          Navigator.pushNamed(context, '/activate');

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
    } else {
      print("Form is invalid.");
    }
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }


    final cleanedValue = value.trim();
  final phonePattern = RegExp(r'^[6-9]\d{8}$');

    if (!phonePattern.hasMatch(cleanedValue)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? validatePassword(String? value){
    final cleanValue = value?.trim();
    print("${cleanValue}, hey");
        if(cleanValue!.length <= 8){
          return "must be 8-characters long";
        }
 }


  Future<http.Response> _createUser(String name, String surname, String email,
      String password, String phone, String city, int role) async {
    print("Hello, $email");

    final response = await http.post(
      Uri.parse("${url}/createUser"),
      body: {
        "name": name,
        "surname": surname,
        "email": email,
        "password": password,
        "phone": phone,
        "city": city,
        "role": role.toString()
      },
    );

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'Assets/taxi.jpg', // Update with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Content on top of the background
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 40.0),
                color: Colors.black26
                    .withOpacity(0.8), // Semi-transparent background
                child: Column(
                  children: [
                    // Text(
                    //   'eTravel',
                    //   style: TextStyle(
                    //     fontSize: 40.0,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.pink,
                    //   ),
                    // ),
                    // SizedBox(height: 10.0),
                    // Text(
                    //   'Sign Up',
                    //   style: TextStyle(
                    //     fontSize: 24.0,
                    //     color: Colors.white,
                    //   ),
                    // ),
                  ],
                ),
              ),
              // Form section
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54, width: 1.0),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0)),
                    color: Colors.white
                        .withOpacity(0.9), // Semi-transparent white background
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey, // Assign the key to the form
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Switch for selecting user type
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sign Up As Driver',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              Transform.scale(
                                scale: 1.2, // Increase the size of the switch
                                child: Switch(
                                  value: isDriver,
                                  onChanged: (value) {
                                    setState(() {
                                      isDriver = value;
                                    });
                                  },
                                  activeColor: Colors
                                      .pink, // Color when the switch is on
                                  inactiveThumbColor: Colors
                                      .white, // Color when the switch is off
                                  inactiveTrackColor:
                                      Colors.black54.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          _buildForm(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _nameController,
                labelText: 'Name',
                icon: Icons.person,
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
                child: _buildTextField(
                    controller: _surnameController,
                    labelText: 'Surname',
                    icon: Icons.person_outline)),
          ],
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email,
                isEmail: true,
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
                child: _buildTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: true,
                    isPassword: true,
                    icon: Icons.lock)),
          ],
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _phoneController,
                labelText: ' +237 Phone',
                icon: Icons.phone,
              isPhone: true
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return cameroonCities.where((String option) {
                    return option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    decoration: InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0), // Slightly rounded corners
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      // Ensure _cityController reflects the latest city value
                      _cityController.text = value;
                    },
                  );
                },
                onSelected: (String selection) {
                  // Update _cityController with the selected city
                  _cityController.text = selection;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0),
        if (isDriver) ...[
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // All fields are valid, proceed with the upload
                int role = 0;

                roles?.forEach((name, id) {
                  if (name == "client") {
                    role = id;
                  } else if (name == "driver" && isDriver) {
                    role = id;
                  }
                });

                _setUserParams(
                    _nameController.text,
                    _surnameController.text,
                    role.toString(),
                    _emailController.text.trim(),
                    _passwordController.text,
                    _cityController.text,
                    _phoneController.text
                );

                Navigator.pushNamed(context, '/upload');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'correct the errors in the form before proceeding.',
                      style: TextStyle(fontSize: 18),
                    ),
                    backgroundColor: Colors.pink,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // No rounded corners
              ),
              backgroundColor: Colors.white54,
              side: BorderSide(color: Colors.pink), // Border color
            ),
            child: Text(
              'Upload Document',

              style: TextStyle(fontSize: 17.0, color: Colors.black),
            ),
          ),
          SizedBox(height: 20.0),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isDriver) // Show the Sign Up button only if not a driverF
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding:
                        EdgeInsets.symmetric(horizontal: 120.0, vertical: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // No rounded corners
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String labelText,
    bool obscureText = false,
    required IconData icon,
    required TextEditingController controller,
    bool isEmail = false,bool isPhone = false, bool isPassword= false
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
      textAlignVertical: TextAlignVertical.center, // Vertically center the text
      validator: (value) {
        value = value?.trim();
        if (value == null || value.isEmpty) {
          print("${value} hello");
          return 'This field is required';
        }
        if (isEmail && !validator.isEmail(value)) {
          print(isEmail);
          return 'Please enter a valid email address';
        }
        if(isPhone){
          return validatePhone(value);
    }
        if(isPassword){
          return validatePassword(value);
        }

        return null;
      },

    );
  }

  Future<void> _setEmail(String email) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString("email", email);
  }

  Future<void> _setUserParams(String name, String surname, String role,
      String email, String password, String city, String phone) async {
    final pref = await SharedPreferences.getInstance();
    // Create a map of attributes
    Map<String, String> attributes = {
      'name': name,
      'surname': surname,
      'email': email,
      'password': password,
      'city': city,
      'phone': phone,
      'role': role
    };
    String jsonString = jsonEncode(attributes);
    await pref.setString('userAttributes', jsonString);


    //validate before Upload
  }
}
