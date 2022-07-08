import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:paint/Database/WebServices/Models/Session.dart';
import 'package:paint/HelperFunctions/GenerateRandomValues.dart';
import 'package:paint/Painter/DrawingArea.dart';

import '../Constants/Variables.dart';
import '../Database/WebServices/DatabaseFunctions.dart';
import '../Painter/PaintOnScreen.dart';

class SessionPage extends StatefulWidget {
  final Session session;
  final bool freeSession;
  const SessionPage({Key? key, required this.session, this.freeSession: false})
      : super(key: key);

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  late DatabaseFunctions databaseFunctions;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedColor = Colors.black;
    strokewidth = 2.0;
    points = [];
    PreviousPoints = [];
    databaseFunctions = DatabaseFunctions();
  }

  void SelectColor() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pick a color!'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  this.setState(() {
                    selectedColor = color;
                  });
                },
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Got it'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.freeSession == false) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Do you want to end session?'),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await databaseFunctions.EndSession(
                              widget.session.Session_ID)
                          .then((value) {
                        if (value == true) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      });
                    },
                    child: Text('Yes'),
                  ),
                ],
              );
            },
          );
          return shouldPop!;
        } else
          return true;
      },
      child: Scaffold(
        body: Stack(
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
                    !widget.freeSession
                        ? StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('Sessions')
                                .doc(widget.session.Session_ID)
                                .collection('count')
                                .doc("s${widget.session.Session_ID}")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.active) {
                                if (!snapshot.hasData) {
                                  return Text(" ");
                                } else {
                                  int count =GetCountFromSnapShot(snapshot);
                                  return Container(
                                    width: scwidth,
                                    color: count > 0
                                        ? Colors.green
                                        : Colors.red,
                                    child: Center(
                                        child: Text(
                                      "${count} Users",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    )),
                                  );
                                }
                              } else {
                                return Text(" ");
                              }
                            })
                        : SizedBox.shrink(),
                    SizedBox(height: scheight * 0.01),
                    !widget.freeSession
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("ID : ${widget.session.Session_ID}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              Text("Pass : ${widget.session.Session_Pass}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ],
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: scheight * 0.01),
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
                      child: GestureDetector(
                        onPanDown: (details) {
                          this.setState(() {
                            points.add(DrawingArea(
                                point: details.localPosition,
                                color: selectedColor,
                                strokewidth: strokewidth,
                                areaPaint:
                                    CurrentPaint(selectedColor, strokewidth)));
                          });
                        },
                        onPanUpdate: (details) {
                          this.setState(() {
                            points.add(DrawingArea(
                                point: details.localPosition,
                                color: selectedColor,
                                strokewidth: strokewidth,
                                areaPaint:
                                    CurrentPaint(selectedColor, strokewidth)));
                          });
                        },
                        onPanEnd: (details) async {
                          this.setState(() {
                            points.add(DrawingArea(
                                point: Offset(-1, -1),
                                color: selectedColor,
                                strokewidth: strokewidth,
                                areaPaint:
                                    CurrentPaint(selectedColor, strokewidth)));
                          });
                          await databaseFunctions.UpdateSessionDrawings(
                              widget.session.Session_ID);
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CustomPaint(
                              painter: MyCustomPainter(
                                  points: points,
                                  color: selectedColor,
                                  strokewidth: strokewidth),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: scheight * 0.01,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      width: scwidth * 0.88,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                SelectColor();
                              },
                              icon: Icon(
                                Icons.color_lens,
                                color: selectedColor,
                              )),
                          Expanded(
                              child: Slider(
                            min: 1,
                            max: 10,
                            activeColor: selectedColor,
                            value: strokewidth,
                            onChanged: (value) {
                              this.setState(() {
                                strokewidth = value;
                              });
                            },
                          )),
                          IconButton(
                              onPressed: () {
                                this.setState(() {
                                  points = List.from(PreviousPoints);
                                });
                              },
                              icon: Icon(Icons.undo)),
                          IconButton(
                              onPressed: () {
                                this.setState(() {
                                  PreviousPoints = List.from(points);
                                  points.clear();
                                });
                              },
                              icon: Icon(Icons.layers))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: scheight * 0.02,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (widget.freeSession) {
                          Navigator.pop(context);
                        } else {
                          await databaseFunctions.EndSession(
                                  widget.session.Session_ID)
                              .then((value) {
                            if (value == true) {
                              Navigator.pop(context);
                            }
                          });
                        }
                      },
                      child: Container(
                        width: scwidth * 0.4,
                        height: scheight * 0.035,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red),
                        child: Center(
                          child: Text(
                            widget.freeSession ? "End Draw" : "End Session",
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
        ),
      ),
    );
  }
}
