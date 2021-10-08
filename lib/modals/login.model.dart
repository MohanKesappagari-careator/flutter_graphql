class Login {
  final String token;
  final String userId;

  Login({required this.token, required this.userId});
  Login copyWith({String? token, String? userId}) {
    return Login(token: token ?? this.token, userId: userId ?? this.userId);
  }
}

class AppState {
  final List<Login> login;
  AppState({required this.login});
  AppState.initialState() : login = List.unmodifiable(<Login>[]);
}
