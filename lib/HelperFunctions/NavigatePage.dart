import 'package:flutter/material.dart';
void NavigateToPage(context,page){
  Navigator.of(context).push(MaterialPageRoute(builder:(context)=>page));
}