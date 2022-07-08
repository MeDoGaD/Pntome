import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:paint/Constants/Variables.dart';
import 'package:paint/Painter/DrawingArea.dart';
import 'Models/Session.dart';

class DatabaseFunctions{
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference sessionsRef=FirebaseFirestore.instance.collection('Sessions');

  Future<bool>CreateSession(Session session)async{
    try{
      await sessionsRef.doc(session.Session_ID).
      set({"session_id":session.Session_ID,
        "session_pass":session.Session_Pass,"drawings":[],"ended":false});
      await sessionsRef.doc(session.Session_ID).collection("count").
      doc("s${session.Session_ID}").set({"count":session.Session_Count});
    }
    catch(e){
      return false;
    }
    finally{
      return true;
    }
  }
  Future<bool>EndSession(String sessionID)async{
    try{
      await sessionsRef.doc(sessionID).update({"ended":true});
    }
    catch(e){
      return false;
    }
    finally{
      return true;
    }
  }
  Future<bool>IncrementSessionUsersCount(String sessionID)async{
    try{
      await GetSessionUsersCount(sessionID).then((value)async{
        await sessionsRef.doc(sessionID).collection("count").
        doc("s${sessionID}").update({"count":value+1}).then((value){
          return;
        });
      });
      return true;
    }
    catch(e){
      return false;
    }
  }
  Future<bool>DecrementSessionUsersCount(String sessionID)async{
    try{
      await GetSessionUsersCount(sessionID).then((value)async{
        await sessionsRef.doc(sessionID).collection("count").
        doc("s${sessionID}").update({"count":value-1}).then((value){
          return;
        });
      });
      return true;
    }
    catch(e){
      return false;
    }
  }
  Future<int>GetSessionUsersCount(String sessionID)async{
    try{
     late int count;
      await sessionsRef.doc(sessionID).collection("count").
      doc("s${sessionID}").get().then((value){
         count=value["count"];
      });
      return count;
    }
    catch(e){
      return 0;
    }
  }
   GetSessionDrawings(String sessionID)async{
    return await sessionsRef.snapshots();
  }
  Future<bool> UpdateSessionDrawings(String SessionID)async{
    try{
      List<Map>drawings=[];
      for(int x=0;x<points.length;x++)
        {
          drawings.add(points[x].ToMap());
        }
      await sessionsRef.doc(SessionID).update({'drawings':drawings});
    }
    catch(e){
      return false;
    }
    finally{
      return true;
    }
}
 Future CheckValidSession(String SessionID,String SessionPass)async{
   bool found=false;
   try{
      await sessionsRef.doc(SessionID).get().then((value) {
        if(value["session_pass"]==SessionPass&&value["ended"]==false)
          {
            found= true;
          }
        else{
          found=false;
        }
      });
    }
    catch(e){
      return false;
    }
    finally{
      return found;
    }
}
}