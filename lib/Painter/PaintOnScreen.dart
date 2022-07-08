import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:paint/Painter/DrawingArea.dart';
class MyCustomPainter extends CustomPainter{
  List<DrawingArea>points;
  Color color;
  double strokewidth;
  MyCustomPainter({required this.points,required this.color,required this.strokewidth});
  @override
  void paint(Canvas canvas, Size size) {
    Paint background=Paint()..color=Colors.white;
    Rect rect=Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    for(int x=0;x<points.length-1;x++)
      {
         if(points[x].point!=Offset(-1,-1)&&points[x+1].point!=Offset(-1,-1)){
           canvas.drawLine(points[x].point, points[x+1].point, points[x].areaPaint);
         }
        else if(points[x].point!=Offset(-1,-1)&&points[x+1].point==Offset(-1,-1)){
          canvas.drawPoints(PointMode.points, [points[x].point], points[x].areaPaint);
        }
      }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
   return true;
  }

}