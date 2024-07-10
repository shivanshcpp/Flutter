import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:samvaad/models/FirebaseHelper.dart';
import 'package:samvaad/pages/CompleteProfile.dart';
import 'package:samvaad/pages/HomePage.dart';
import 'package:samvaad/pages/LoginPage.dart';
import 'package:samvaad/pages/SignUpPage.dart';
import 'package:uuid/uuid.dart';
import 'models/UserModel.dart';

var uuid=Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentUser=FirebaseAuth.instance.currentUser;
  if(currentUser!=null){
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
    if(thisUserModel!=null){
      runApp(MyAppLoggedIn(userModel: thisUserModel, fireBaseUser: currentUser));
      //runApp(const MyApp());
    }
    else{
      runApp(const MyApp());
    }

  }
  else{
    runApp(const MyApp());
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User fireBaseUser;

  const MyAppLoggedIn({super.key, required this.userModel, required this.fireBaseUser});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel,firebaseUser: fireBaseUser),
    );
  }
}