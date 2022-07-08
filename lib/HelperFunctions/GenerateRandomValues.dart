import 'dart:math';

String GenerateRandomID(){
  var range=Random();
  return range.nextInt(100000000).toString();
}
String GenerateRandomPass(){
  var r = Random();
  const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(6, (index) => _chars[r.nextInt(_chars.length)]).join();
}
int GetCountFromSnapShot(snapshot){
  return snapshot.data["count"];
}