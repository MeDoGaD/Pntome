import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint/Database/WebServices/DatabaseFunctions.dart';
import 'package:paint/Database/WebServices/Models/Session.dart';
import 'package:paint/Painter/DrawingArea.dart';
import '../Constants/Variables.dart';
import '../Painter/PaintOnScreen.dart';

class LiveSessionPage extends StatefulWidget {
  final Session session;
  const LiveSessionPage({Key? key,required this.session}) : super(key: key);

  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage> {
  Stream? drawingsStream;
  List<DrawingArea>LiveDrawings=[];
  DatabaseFunctions databaseFunctions=DatabaseFunctions();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedColor=Colors.black;
    strokewidth=2.0;
  }
  Widget showLoadingIndicator() {
    return Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ));
  }
  showAlert(){
    return  showDialog(context: context, builder:(BuildContext context){
      return AlertDialog(title:Text("The Session creator has end the session !") ,
        actions: [
          FlatButton(child: Text("Ok"),onPressed: (){
            Navigator.pop(context);
            Navigator.pop(context);
          },),

        ],);
    });
  }
  Widget BuildLiveSessionBody(){
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(138, 35, 135, 1.0),
                    Color.fromRGBO(233, 64, 87, 1.0),
                    Color.fromRGBO(242, 113, 33, 1.0),
                  ])),
        ),
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: scwidth * 0.88,
                  height: scheight * 0.8,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 5.0,
                            spreadRadius: 1.0)
                      ]),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomPaint(
                        painter: MyCustomPainter(
                            points: LiveDrawings,
                            color: selectedColor,
                            strokewidth: strokewidth),
                      )),

                ),
                SizedBox(height: scheight*0.02,),
                GestureDetector(onTap: ()async{
                 await databaseFunctions.DecrementSessionUsersCount(widget.session.Session_ID)
                     .then((value){
                   Navigator.pop(context);
                 });
                },
                  child: Container(
                    width: scwidth * 0.4,height: scheight*0.035,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.red),
                    child: Center(
                      child: Text(
                        "Leave",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
      return WillPopScope(onWillPop:()async{
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title:  Text('Do you want to leave?'),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text('No'),
                ),
                TextButton(
                  onPressed: () async{
                    await databaseFunctions.DecrementSessionUsersCount(widget.session.Session_ID)
                        .then((value){
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  },
                  child:Text('Yes'),
                ),

              ],
            );
          },
        );
        return shouldPop!;
      } ,
        child: Scaffold(
            body: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Sessions').doc(
                  widget.session.Session_ID).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (!snapshot.hasData) {
                    return showLoadingIndicator();
                  }
                  else {
                    LiveDrawings = DrawingArea.fromSnapShot(snapshot);
                    bool ended=Session.CheckEnded(snapshot);
                    if(ended==true)
                      {
                        showAlert();
                      }
                    return BuildLiveSessionBody();
                  }
                }
                else {
                  return showLoadingIndicator();
                }
              },)
        ),
      );
    }
  }

