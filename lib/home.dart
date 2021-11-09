import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
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
    return Container(
        padding: const EdgeInsets.all(2),
        child: Query(
            options: QueryOptions(
              document: gql("""
 query user(\$id:String!){
  user(id:\$id){
    email
    username
    avatar
    role
  }
}
  """),
              variables: {'id': userId},
            ),
            builder: (QueryResult result, {fetchMore, refetch}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }
              if (result.isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final emailData = result.data!['user']['email'];
              final nameData = result.data!['user']['username'];
              final prifilePic = result.data!['user']['avatar'];
              final role = result.data!['user']['role'];
              print("database");
              print(emailData);
              print(nameData);
              print(prifilePic);
              print(role);

              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 200,
                            margin: EdgeInsets.all(10),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(90),
                                child: prifilePic == null
                                    ? Image.asset("assets/images/default.jpg")
                                    : null),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                    ),
                    ListTile(
                      leading: Text(
                        "UserName :",
                        style: TextStyle(
                          color: Colors.brown,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      title: Text(nameData,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ),
                    ListTile(
                        leading: Text("Email :",
                            style: TextStyle(
                                color: Colors.brown,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        title: Text(emailData,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w800))),
                    ListTile(
                        leading: Text("Role :",
                            style: TextStyle(
                                color: Colors.brown,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        title: Text(role,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w800))),
                  ],
                ),
              );
            }));
  }
}
