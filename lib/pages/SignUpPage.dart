import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:samvaad/models/UserModel.dart';
import 'package:samvaad/pages/CompleteProfile.dart';
import 'package:samvaad/pages/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/UIHelper.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();
    if (email == "" || password == "" || cPassword == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
    } else if (password != cPassword) {
      UIHelper.showAlertDialog(context, "Password Mismatch",
          "The passwords you entered do not match!");
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Creating new account..");
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);

      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, fullname: "", profilepic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        print("New User Created");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return CompleteProfile(
              userModel: newUser,
              firebaseUser: credential!.user!,
            );
          }),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Samvaad",
            style: GoogleFonts.dancingScript(
                textStyle: const TextStyle(
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
                  Text("Register",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            color: Colors.indigo,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      )),
                  Container(
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
                      child: Text("You and your friends always connected",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(color: Colors.black54),
                          ))),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: "Email Address",
                        icon: Icon(Icons.email_outlined)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Password",
                        icon: Icon(Icons.lock_person_outlined)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: cPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Confirm Password",
                        icon: Icon(Icons.lock_person_outlined)),
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
                      "Sign Up",
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
            Text("Already have an Account?",
                style: GoogleFonts.inter(
                  textStyle: TextStyle(fontSize: 16),
                )),
            CupertinoButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }),
                );
              },
              child: Text("Login", style: GoogleFonts.inter()),
            )
          ],
        ),
      ),
    );
  }
}
