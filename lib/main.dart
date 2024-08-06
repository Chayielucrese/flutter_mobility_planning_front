import 'package:flutter/material.dart';



import 'Routes/app.routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

return MaterialApp(
  title: "eTRAVEL APP",
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize:25,
        fontWeight: FontWeight.bold
      )
    )
  ),
  initialRoute: '/',
  routes: AppRoutes.routes,
);
  }


}