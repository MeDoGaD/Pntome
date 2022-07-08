import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class DrawingArea {
  Offset point;
  Color color;
  double strokewidth;
  Paint areaPaint;
  DrawingArea({required this.point, required this.color,required this.strokewidth,required this.areaPaint});
  Map<String , dynamic>ToMap(){
return{
  'xPoint':point.dx,
  'yPoint':point.dy,
  'color':color.toString(),
  'width':strokewidth
};
}

static List<DrawingArea>fromSnapShot(snap){
  List<DrawingArea>retrievedPoints=[];
  List drawings=snap.data['drawings'];
      for(int i=0;i<drawings.length;i++)
      {
        String colorString=drawings[i]['color'];
        String valueString = colorString.split('(0x')[1].split(')')[0];
        int value = int.parse(valueString, radix: 16);
        DrawingArea drawingArea=
        DrawingArea(point:Offset(drawings[i]['xPoint'],drawings[i]['yPoint'])
            , color:Color(value),
            strokewidth:drawings[i]['width'],
            areaPaint:CurrentPaint(Color(value), drawings[i]['width']));
        retrievedPoints.add(drawingArea);
      }
    return retrievedPoints;
}
}
Paint CurrentPaint(Color selectedColor, double strokewidth) {

  return Paint()
    ..color = selectedColor
    ..isAntiAlias = true
    ..strokeWidth = strokewidth
    ..strokeCap = StrokeCap.round;
}
