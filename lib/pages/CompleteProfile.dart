import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samvaad/models/UserModel.dart';
import 'package:samvaad/pages/HomePage.dart';

import '../models/UIHelper.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 30,
    );
    if (croppedFile != null) {
      setState(() {
        imageFile = File(croppedFile.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Upload Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                leading: Icon(Icons.camera_alt_rounded),
                title: Text("Take a Photo"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                leading: Icon(Icons.photo_album_rounded),
                title: Text("Select from gallery"),
              ),
            ],
          ),
        );
      },
    );
  }

  void checkValues() {
    String fullname = fullNameController.text.trim();
    if (fullname.isEmpty || imageFile == null) {
      print("Please fill all the fields");
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields and upload a profile picture");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UIHelper.showLoadingDialog(context, "Uploading image..");
    if (widget.userModel.uid == null) {
      print("User UID is null");
      return;
    }

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid!)
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullName = fullNameController.text.trim();

    widget.userModel.fullname = fullName;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      print("Data Uploaded");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context){
        return HomePage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
      }),);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              SizedBox(height: 20),
              CupertinoButton(
                onPressed: showPhotoOptions,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: imageFile != null ? FileImage(imageFile!) : null,
                  child: imageFile == null
                      ? Icon(Icons.person_rounded, size: 60)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                ),
              ),
              SizedBox(height: 20),
              CupertinoButton(
                onPressed: () {checkValues();},
                color: Colors.indigo,
                child: Text(
                  "Submit",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CompleteProfile(
      userModel: UserModel(),
      firebaseUser: FirebaseAuth.instance.currentUser!,
    ),
  ));
}
