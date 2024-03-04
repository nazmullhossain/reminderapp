import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String message,{ToastGravity? position}) => Fluttertoast.showToast(
    msg: message,
    toastLength:Toast.LENGTH_SHORT,
    gravity: position?? ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0);