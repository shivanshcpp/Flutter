import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:samvaad/models/UserModel.dart';
import 'package:samvaad/pages/ChatRoomPage.dart';

import '../main.dart';
import '../models/ChatRoomModel.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async{
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}", isEqualTo: true).where("participants.${targetUser.uid}", isEqualTo: true).get();
    if(snapshot.docs.length>0){
      var docData= snapshot.docs[0].data();
      ChatRoomModel existingChatroom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom=existingChatroom;
    }
    else{
      ChatRoomModel newChatRoom=ChatRoomModel(
          chatroomid : uuid.v1(),
          lastMessage : "",
          participants : {
            widget.userModel.uid.toString() : true,
            targetUser.uid.toString() : true,
          }
      );
      await FirebaseFirestore.instance.collection("chatrooms").doc(newChatRoom.chatroomid).set(newChatRoom.toMap());
      chatRoom=newChatRoom;
      log("New Chatroom Created!");

    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          "Search",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(labelText: "Email Address"),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                color: Colors.indigo,
                child: Text(
                  "Search",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("email", isEqualTo: searchController.text).where("email",isNotEqualTo : widget.userModel.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                        snapshot.data as QuerySnapshot;
                        if (dataSnapshot.docs.length > 0) {
                          Map<String, dynamic> userMap = dataSnapshot.docs[0]
                              .data() as Map<String, dynamic>;
                          UserModel searchedUser = UserModel.fromMap(userMap);
                          return ListTile(
                            onTap: () async{
                              ChatRoomModel? chatroomModel = await getChatRoomModel(searchedUser);
                              if(chatroomModel != null) {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return ChatRoomPage(
                                      targetUser: searchedUser,
                                      userModel: widget.userModel,
                                      firebaseUser: widget.firebaseUser,
                                      chatroom: chatroomModel,
                                    );
                                  },
                                ));
                              }
                            },
                            leading: CircleAvatar(
                              backgroundImage:
                              NetworkImage(searchedUser.profilepic!),
                            ),
                            title: Text(searchedUser.fullname.toString()),
                            subtitle: Text(searchedUser.email.toString()),
                            trailing: Icon(Icons.arrow_right_alt_outlined),
                          );
                        } else {
                          return Text("No results found...");
                        }
                      } else if (snapshot.hasError) {
                        return Text("An error occured...");
                      } else {
                        return Text("No results found...");
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
