import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:samvaad/models/UIHelper.dart';
import 'package:samvaad/models/UserModel.dart';
import 'package:samvaad/pages/SignUpPage.dart';
import 'package:samvaad/pages/HomePage.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email == "" || password == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Logging In...");
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
      //print(ex.message.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);
      print("Log in Successful");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomePage(
              userModel: userModel, firebaseUser: credential!.user!);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Samvaad",
            style: GoogleFonts.dancingScript(
                textStyle: TextStyle(
                    fontSize: 39,
                    color: Colors.white,
                    fontWeight: FontWeight.bold))),
        backgroundColor: Color(0xFF083663),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Login",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            color: Colors.indigo,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      )),
                  Container(
                      padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
                      child: Text(
                        "Remember to get up & stretch once \n in a while - your friends at chat.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(textStyle: TextStyle(color: Colors.black54),)
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email Address",icon: Icon(Icons.email_outlined)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Password",icon: Icon(Icons.lock_person_outlined)),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      checkValues();
                    },
                    color: Colors.indigo,
                    child: Text(
                      "Log In",
                      style: TextStyle(fontSize: 16),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(60, 0, 30, 20),
        child: Row(
          children: [
            Text(
              "Don't have an Account?",
              style: GoogleFonts.inter(textStyle: TextStyle(fontSize: 16),)
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return SignUpPage();
                  }),
                );
              },
              child: Text("Sign up here",style: GoogleFonts.inter(),),
            )
          ],
        ),
      ),
    );
  }
}
