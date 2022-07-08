
import '../../../Painter/DrawingArea.dart';

class Session{
   String Session_ID;
   String Session_Pass;
   int Session_Count;
   List<DrawingArea>points;
   bool ended;
   Session({required this.Session_ID,required this.Session_Pass,this.Session_Count:0,required this.points,this.ended:false});
static CheckEnded(snap){
   bool ended= snap.data["ended"];
   return ended;
}
}