import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint/Constants/Variables.dart';
import 'package:paint/Database/WebServices/DatabaseFunctions.dart';
import 'package:paint/HelperFunctions/GenerateRandomValues.dart';
import 'package:paint/HelperFunctions/NavigatePage.dart';
import 'package:paint/Pages/LiveSessionPage.dart';
import 'package:paint/Pages/SessionPage.dart';

import '../Database/WebServices/Models/Session.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  TextEditingController sessionID=TextEditingController();
  TextEditingController sessionPass=TextEditingController();

  late DatabaseFunctions databaseFunctions;
  @override
  void initState() {
    super.initState();
    databaseFunctions = DatabaseFunctions();
  }
showAlert(){
    return  showDialog(context: context, builder:(BuildContext context){
      return AlertDialog(title:Text("Invalid Session Info") ,
        actions: [
          FlatButton(child: Text("Ok"),onPressed: (){
            Navigator.pop(context);
          },),

        ],);
    });
}
  ShowDialog() {
    sessionID.clear();
    sessionPass.clear();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Color.fromRGBO(138, 35, 135, 1.0),
                  Color.fromRGBO(233, 64, 87, 1.0),
                  Color.fromRGBO(242, 113, 33, 1.0),
                ])),
            child: AlertDialog(
              title: Center(child: Text("Enter Session Info")),
              content: Container(
                width: scwidth * 0.7,height: scheight*0.15,
                child: Column(
                  children: [
                    Container(
                      width: scwidth * 0.6,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 2)),
                      child: Padding(
                        padding: EdgeInsets.only(left: scwidth * 0.02),
                        child: TextField(controller:sessionID ,
                          decoration: InputDecoration(
                              hintText: "Session ID : ",
                              border: InputBorder.none),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: scheight * 0.01,
                    ),
                    Container(
                      width: scwidth * 0.6,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 2)),
                      child: Padding(
                        padding: EdgeInsets.only(left: scwidth * 0.02),
                        child: TextField(controller: sessionPass,
                          decoration: InputDecoration(
                              hintText: "Session Pass : ",
                              border: InputBorder.none),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                GestureDetector(onTap: ()async{
                  await databaseFunctions.CheckValidSession(sessionID.text, sessionPass.text).then((value) async {
                    if(value==true)
                      {
                        await databaseFunctions.IncrementSessionUsersCount(sessionID.text);
                        NavigateToPage(context,
                            LiveSessionPage(session:Session(points: [],Session_ID:sessionID.text,
                                Session_Pass:sessionPass.text,Session_Count: 1 )));
                      }
                    else
                      {
                        showAlert();
                      }
                  });
                },
                  child: Container(
                    width: scwidth * 0.4,height: scheight*0.035,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.green),
                    child: Center(
                      child: Text(
                        "Join Now",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    scwidth = MediaQuery.of(context).size.width;
    scheight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: scheight * 0.08,
            ),
            Text(
              "Pntome",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: scwidth/10,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: scheight * 0.04,
            ),
            Container(
              width: scwidth * 0.84,
              height: scheight * 0.55,
              child: Image.asset(
                "assets/start.png",
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(
              height: scheight * 0.07,
            ),
            GestureDetector(
              onTap: () async {
                Session session = Session(
                    points: [],
                    Session_ID: "1",
                    Session_Pass: "1");
                NavigateToPage(
                    context,
                    SessionPage(
                      session: session,freeSession:true,
                    ));
              },
              child: Container(
                width: scwidth * 0.5,
                height: scheight * 0.05,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                    child: Text("Free Draw",
                        style: TextStyle(color: Colors.white, fontSize: 22))),
              ),
            ),
            SizedBox(
              height: scheight * 0.01,
            ),
            GestureDetector(
              onTap: () async {
                String SessionID = GenerateRandomID();
                String SessionPass = GenerateRandomPass();
                Session session = Session(
                    points: [],
                    Session_ID: SessionID,
                    Session_Pass: SessionPass);
                await databaseFunctions.CreateSession(session);
                NavigateToPage(
                    context,
                    SessionPage(
                      session: session
                    ));
              },
              child: Container(
                width: scwidth * 0.65,
                height: scheight * 0.05,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                    child: Text("Start Session",
                        style: TextStyle(color: Colors.white, fontSize: 22))),
              ),
            ),
            SizedBox(
              height: scheight * 0.01,
            ),

            GestureDetector(
              onTap: () {
                ShowDialog();
              },
              child: Container(
                width: scwidth * 0.8,
                height: scheight * 0.05,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                    child: Text("Join Session",
                        style: TextStyle(color: Colors.white, fontSize: 22))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
