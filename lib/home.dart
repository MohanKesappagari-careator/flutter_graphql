import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

checkPrefsForUser() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  var _sharedToken = _prefs.getString('token');
  var _sharedId = _prefs.getString('userId');
  print('USERID:');
  print(_sharedId);
  print('TOKEN');
  print(_sharedToken);

  userId = _sharedId;
  auth = _sharedToken;
  print('QQQQQQQQQQQQQQQQQQQQQQQQ');
}

var userId;
var auth;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    checkPrefsForUser();
  }

  Widget build(BuildContext context) {
    return Scaffold(body: Text(auth ?? 'no userId'));
  }
}
