import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/modals/login.model.dart';
import 'package:flutter_demo/redux/action.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(login: loginReducer(state.login, action));
}

List<Login> loginReducer(List<Login> state, action) {
  if (action is Addlogin) {
    return []
      ..addAll(state)
      ..add(Login(token: action.login.token, userId: action.login.userId));
  }
  return state;
}
