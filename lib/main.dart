import 'package:flutter/material.dart';

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
void upDateSharedPreferences(String token, String userId) async {
  print(token);
  print(userId);
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString('token', token);
  _prefs.setString('userId', userId);
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
    getToken: () async =>
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6Im1vaGFuIiwic3ViIjoiODY0NzM5YmItZWM5Mi00MTQwLThhMWYtYmU4OTJiYTY2ODI2IiwiZW1haWwiOiJtb2hhbkBnbWFpbC5jb20iLCJyb2xlIjpudWxsLCJpYXQiOjE2MzI1NjIyNzksImV4cCI6MTYzMjU2NTg3OX0.96ijTlQYnHv3TSJyoiZNH4mN_FlfyeEis79C27tdOCM',
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Helllo'),
          backgroundColor: Colors.amberAccent,
        ),
        body: Mutation(
          // ignore: deprecated_member_use
          options: MutationOptions(document: gql(login)),
          builder: (runMutation, result) {
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
                      controller: postUserNameController,
                      decoration: const InputDecoration(
                        hintText: 'Post UserName',
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
                    TextField(
                      controller: postRoleController,
                      decoration: const InputDecoration(
                        hintText: 'Post Role',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        runMutation({
                          'email': postEmailController.text,
                          'password': postPasswordController.text
                        });
                        if (result?.data == null) {
                          return null;
                        } else {
                          var userId = result?.data!['login']['userId'];
                          var token = result?.data!['login']['token'];
                          upDateSharedPreferences(token, userId);
                          checkPrefsForUser();
                        }
                      },
                      child: const Text('Create Post'),
                    ),
                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.white,
                        child: Text(
                          result?.data == null
                              ? '''Post details coming up shortly,'''
                                  ''' Kindly enter details and create a post'''
                              : result?.data?['login']['userId'],
                        ),
                      ),
                    ),
                    Card(
                      child: Text(userId ?? 'nodata'),
                    ),
                    Card(
                      child: Text(auth ?? 'no token'),
                    )
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
