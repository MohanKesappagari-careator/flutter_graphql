import 'package:flutter/material.dart';
import 'package:flutter_demo/home.dart';
import 'package:flutter_demo/modals/login.model.dart';
import 'package:flutter_demo/redux/reducer.dart';
import 'package:get/get.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const user = """
query {
  alluser{
    email
    username
  }
}
""";
const adduser = """
mutation createUser(\$email: String!, \$password: String!,\$username:String!,\$role:String!){
  createUser(
    createUserInput:{
    email: \$email
    password: \$password
    role: \$role
    username: \$username
  }
  ){
    id
    email
    
  }
}
""";

const edit = """
mutation updateUser(\$email: String!, \$password: String!,\$username:String!,\$role:String!){
  updateUser(
    updateUserInput:{
    id:"630185e4-d4ae-4c10-83e6-77e0f5b260a6"
    email: \$email
    password: \$password
    role: \$role
    username: \$username
  }
  ){
    id
    email
    
  }
}
""";
const login = """
mutation login(\$email:String!,\$password:String!){
   login(login:{
    email:\$email
    password:\$password
  }){
    token
    userId
  }
}
""";
Future upDateSharedPreferences(String token, String userId) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString('token', token);
  await _prefs.setString('userId', userId);

//   SharedPreferences _prefs = await SharedPreferences.getInstance();
  var _sharedToken = _prefs.getString('token');
  var _sharedId = _prefs.getString('userId');
  print(_sharedId);
  print(_sharedToken);
}

checkPrefsForUser() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  var _sharedToken = _prefs.getString('token');
  var _sharedId = _prefs.getString('userId');
  print(_sharedId);
  print(_sharedToken);
  userId = _sharedId;
  auth = _sharedToken;
}

final postEmailController = TextEditingController();
final postPasswordController = TextEditingController();
final postUserNameController = TextEditingController();
final postRoleController = TextEditingController();
var userId;
var auth;
//var session = FlutterSession()

void main() async {
  final HttpLink httpLink = HttpLink(
    'http://localhost:5000/graphql',
  );

  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer $auth',
    // OR
    // getToken: () => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
  );

  final Link link = authLink.concat(httpLink);
  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
      // The default store is the InMemoryStore, which does NOT persist to disk
    ),
  );
  var app = GraphQLProvider(
    client: client,
    child: MyApp(),
  );
  runApp(app);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Helllo'),
          backgroundColor: Colors.amberAccent,
        ),
        body: Mutation(
          // ignore: deprecated_member_use
          options: MutationOptions(
            document: gql(login),
            onCompleted: (dynamic resultData) {
              var userId = resultData?['login']['userId'];
              var token = resultData?['login']['token'];
              print(userId);
              print(token);
              upDateSharedPreferences(token, userId);
              checkPrefsForUser();
              print(resultData?['login']['token']);
              Get.to(HomeScreen());
            },
          ),
          builder: (runMutation, result) {
            if (result!.hasException) {
              return Text(result.exception.toString());
            }

            if (result.isLoading) {
              return Center(
                child: const CircularProgressIndicator(),
              );
            }

            //var data = result?.data?['login'];
            //print(data);

            // return ListView.builder(
            //     itemCount: repositories.length,
            //     itemBuilder: (context, index) {
            //       final repository = repositories[index];

            //       return Text(repository['username']);
            //     });
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: postEmailController,
                      decoration: const InputDecoration(
                        hintText: 'Post Email',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    TextField(
                      controller: postPasswordController,
                      decoration: const InputDecoration(
                        hintText: 'Post Password',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        runMutation({
                          'email': postEmailController.text,
                          'password': postPasswordController.text
                        });
                      },
                      child: const Text('Login'),
                    ),
                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.white,
                        child: Text(
                          result.data == null
                              ? '''Post details coming up shortly,'''
                                  ''' Kindly enter details and create a post'''
                              : result.data?['login']['userId'],
                        ),
                      ),
                    ),
                    Card(
                      child: Text(userId ?? 'login userId'),
                    ),
                    Card(
                      child: Text(auth ?? 'login token'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // body: Query(
        //   options: QueryOptions(document: gql(user)),
        //   builder: (QueryResult result, {refetch, fetchMore}) {
        //     if (result.hasException) {
        //       return Text(result.exception.toString());
        //     }

        //     if (result.isLoading) {
        //       return Text('Loading');
        //     }

        //     // it can be either Map or List
        //     List repositories = result.data!['alluser'];
        //     print(repositories);

        //     return ListView.builder(
        //         itemCount: repositories.length,
        //         itemBuilder: (context, index) {
        //           final repository = repositories[index];

        //           return Text(repository['username']);
        //         });
        //   },
        // )
      ),
    );
  }
}
