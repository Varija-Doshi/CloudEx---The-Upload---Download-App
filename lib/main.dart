import 'package:electura/screens/login.dart';
import 'package:electura/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:electura/provider_widget.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: AuthService(),
      child: MaterialApp(
        title: ('Login'),
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: SignUpView(authFormType: AuthFormType.signUp),
      ),
    );
  }
}
