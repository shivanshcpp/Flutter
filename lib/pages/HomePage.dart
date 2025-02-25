import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:samvaad/models/UserModel.dart';
import 'package:samvaad/pages/SearchPage.dart';

import '../models/ChatRoomModel.dart';
import '../models/FirebaseHelper.dart';
import 'ChatRoomPage.dart';
import 'LoginPage.dart';

class HomePage extends StatefulWidget{
  final UserModel userModel;
  final User firebaseUser;

  const HomePage({super.key, required this.userModel,required this.firebaseUser});


  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages",
            style: GoogleFonts.baskervville(
                textStyle: TextStyle(
                    fontSize: 32,
                    color: Colors.white,

                    ))),
        backgroundColor: Color(0xFF083663),
        actions: [
          Tooltip(
            message: "Log out",
            child: IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) {
                        return LoginPage();
                      }
                  ),
                );
              },
              icon: Icon(Icons.exit_to_app,color: Colors.black,),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}", isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.active) {
                if(snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(chatRoomSnapshot.docs[index].data() as Map<String, dynamic>);

                      Map<String, dynamic> participants = chatRoomModel.participants!;

                      List<String> participantKeys = participants.keys.toList();
                      participantKeys.remove(widget.userModel.uid);

                      return FutureBuilder(
                        future: FirebaseHelper.getUserModelById(participantKeys[0]),
                        builder: (context, userData) {
                          if(userData.connectionState == ConnectionState.done) {
                            if(userData.data != null) {
                              UserModel targetUser = userData.data as UserModel;

                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                        chatroom: chatRoomModel,
                                        firebaseUser: widget.firebaseUser,
                                        userModel: widget.userModel,
                                        targetUser: targetUser,
                                      );
                                    }),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(targetUser.profilepic.toString()),
                                ),
                                title: Text(targetUser.fullname.toString(),style: GoogleFonts.inter(textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ), )
                                  ),
                                subtitle: (chatRoomModel.lastMessage.toString() != "") ? Text(chatRoomModel.lastMessage.toString()) : Text("Say hi to your new friend!", style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),),
                                shape: Border(
                                  bottom: BorderSide(color: Colors.black26, width: 1),
                                ),
                              );
                            }
                            else {
                              return Container();
                            }
                          }
                          else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                }
                else if(snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                else {
                  return Center(
                    child: Text("No Chats"),
                  );
                }
              }
              else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context,
          MaterialPageRoute(builder: (context){
            return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }),);
        },
        child: Icon(Icons.search_rounded),
        hoverColor: Colors.indigo,

      ),
    );
  }
}