
import 'package:flutter/cupertino.dart';
import 'package:your_project_name/Pages/activation.page.dart';
import 'package:your_project_name/Pages/client.home.page.dart';
import 'package:your_project_name/Pages/driver.home.page.dart';
import 'package:your_project_name/Pages/login.page.dart';
import 'package:your_project_name/Pages/signup_page.dart';
import 'package:your_project_name/Pages/upload.document.dart';
import 'package:your_project_name/Pages/welcome.screen.dart';


// import '../Pages/driver.dashboard.dart';
import '../Pages/waiting.page.dart';

class AppRoutes{
  static Map<String, WidgetBuilder> routes ={
    '/': (context) => WelcomeScreen(),
    '/login': (context)=>LoginPage(),
    '/signup': (context)=>SignUpPage(),
    '/upload': (context)=>UploadPage(),
    '/activate': (context)=> ActivationPage(),
    '/client': (context)=> ClientHomePage(),
    '/driver': (context)=> WelcomePage(),
    '/Confirmation': (context)=> RegistrationConfirmationPage(),
    // '/dashboard': (context)=>DriverDashboardPage(),
  };
}