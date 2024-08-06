import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

const url = 'http://192.168.137.1:9000/api';

class _UploadPageState extends State<UploadPage> {
  File? drivingLicence;
  File? cni;
  File? photo;
  File? vehiclePhoto;

  Future<http.Response> _createUser(
      String name,
      String surname,
      String email,
      String password,
      String phone,
      String city,
      int role,
      String drivingLicense,
      String vehiclePhoto,
      String imageProfile,
      String CNI) async {
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
        "role": role.toString(),
        "drivingLicense": drivingLicense,
        "vehiclePhoto": vehiclePhoto,
        "profileImage": imageProfile,
        "CNI": CNI
      },
    );

    return response;
  }

  Future<String> _getUserEmail() async {
    Map<String, String> userParams = await _getUserParams();
    return userParams['email'] ?? 'Unknown';
  }

  Future<String> _getUserPhone() async {
    Map<String, String> userParams = await _getUserParams();
    return userParams['phone'] ?? 'Unknown';
  }

  Future<String> _getUserPassword() async {
    Map<String, String> userParams = await _getUserParams();
    return userParams['password'] ?? 'Unknown';
  }

  Future<String> _getUserName() async {
    Map<String, String> userParams = await _getUserParams();
    return userParams['name'] ?? 'Unknown';
  }

  Future<String> _getUserRole() async {
    Map<String, String> userParams = await _getUserParams();
    return userParams['role'] ?? 'Unknown';
  }

  Future<String> _getUserSurname() async {
    Map<String, String> userParams = await _getUserParams();
    return userParams['surname'] ?? 'Unknown';
  }

  Future<String> _getUserCity() async {
    Map<String, String> userParams = await _getUserParams();
    return userParams['city'] ?? 'Unknown';
  }

  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        File selectedFile = File(pickedFile.path);
        switch (index) {
          case 0:
            drivingLicence = selectedFile;
            break;
          case 1:
            cni = selectedFile;
            break;
          case 2:
            photo = selectedFile;
            break;
          case 3:
            vehiclePhoto = selectedFile;
            break;
        }
      });
    }
  }

  Future<String> getBase64(File file) async {
    String? base64;
    String fileExtension = file.path.split('.').last.toLowerCase();
    // Assume content type based on file extension
    String contentType =
    fileExtension.contains('jpg') || fileExtension.contains('jpeg')
        ? 'image/jpeg'
        : fileExtension.contains('png')
        ? 'image/png'
        : 'unknown';

    if (contentType != 'unknown') {
      final uInt8List = await file.readAsBytes();
      base64 = base64Encode(uInt8List);
      base64 = 'data:$contentType;base64,$base64';
    }
    print("contentType: $contentType");
    return base64 ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Documents',
          style: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.3,
              padding: EdgeInsets.only(top: 20.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('Assets/upload.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 20.0),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        String label;
                        IconData icon;
                        File? imageFile;

                        switch (index) {
                          case 0:
                            label = 'Driving Licence';
                            icon = Icons.card_membership;
                            imageFile = drivingLicence;
                            break;
                          case 1:
                            label = 'CNI';
                            icon = Icons.credit_card;
                            imageFile = cni;
                            break;
                          case 2:
                            label = 'Photo';
                            icon = Icons.photo_camera;
                            imageFile = photo;
                            break;
                          case 3:
                            label = 'Vehicle Photo';
                            icon = Icons.directions_car_filled;
                            imageFile = vehiclePhoto;
                            break;
                          default:
                            label = 'Upload';
                            icon = Icons.add_a_photo;
                            imageFile = null;
                        }

                        return GestureDetector(
                          onTap: () => _pickImage(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Stack(
                              children: [
                                if (imageFile != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.file(
                                      imageFile,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                else
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          icon,
                                          color: Colors.black,
                                          size: 50.0,
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          label,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (drivingLicence != null &&
                            cni != null &&
                            vehiclePhoto != null &&
                            photo != null) {
                          String base64StringLicense =
                          await getBase64(drivingLicence!);
                          String base64StringCNI = await getBase64(cni!);
                          String base64StringVehiclePhoto =
                          await getBase64(vehiclePhoto!);
                          String base64StringUserTof = await getBase64(photo!);
                          String name = await _getUserName();
                          String surname = await _getUserSurname();
                          String email = await _getUserEmail();
                          String phone = await _getUserPhone();
                          String city = await _getUserCity();
                          String password = await _getUserPassword();
                          String role = await _getUserRole();

                          print("role: ${role}");

                          try {
                            final response = await _createUser(
                                name,
                                surname,
                                email,
                                password,
                                phone,
                                city,
                                int.parse(role),
                                base64StringLicense,
                                base64StringCNI,
                                base64StringVehiclePhoto,
                                base64StringUserTof);
                            if (response.statusCode == 200 || response.statusCode == 201 ) {
                              print("User created successfully.");
                              Navigator.pushNamed(context, '/activate');



                            }
                            else{
                              final errorResponse = json.decode(response.body);
                              print(
                                  "Registration failed: ${errorResponse['msg']}");

                              print(response.body);

                              SharedPreferences prefs =
                              await SharedPreferences.getInstance();
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


                            }
                          } catch (e) {
                            print("Error occurred during registration: $e");
                          }


                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Upload all require documents",
                                style: TextStyle(fontSize: 18),
                              ),
                              backgroundColor: Colors.pink,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: EdgeInsets.symmetric(
                            horizontal: 60.0, vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  Future<void>setDriverToken(String token) async{
    final pref = await SharedPreferences.getInstance();
     pref.setString("token", token);
  }
}
