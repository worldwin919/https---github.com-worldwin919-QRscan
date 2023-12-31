import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ins_scan/models/scans.dart';
import 'package:ins_scan/pages/home.dart';

void main() {

  runApp(ChangeNotifierProvider(
  
      create: (context) => ScansModel(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'MassQR',
        theme: ThemeData(
            primarySwatch: Colors.amber,
            primaryColor: Colors.amber,
            brightness: Brightness.light),
        darkTheme: ThemeData(
            primarySwatch: Colors.amber,
            primaryColor: Colors.amber,
            brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        home: HomePage());
  }
}
