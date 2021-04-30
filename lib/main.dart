
import 'package:flutter/material.dart';
import 'package:flutter_line_login/home.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LineSDK.instance.setup("1655657817").then((_) {
    print("LineSDK Prepared");
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

