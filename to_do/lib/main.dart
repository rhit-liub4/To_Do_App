import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:to_do/pages/to_do_list_page.dart';
import 'firebase_options.dart';

//(Code adapted and worked on with Dr.Fisher in class)
//(Work moved from photo bucket --> to-do app)

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(
        clientId:
        "241570666356-6iov3qjio5gqetunhk1ma5ilhqbf8vd8.apps.googleusercontent.com"),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const ToDoListPage(),
    );
  }
}




