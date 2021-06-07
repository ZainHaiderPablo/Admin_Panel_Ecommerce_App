import 'package:flutter/material.dart';
import 'package:admin_side_flutter_app/screens/admin.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
       new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Admin(),
  ));
}

