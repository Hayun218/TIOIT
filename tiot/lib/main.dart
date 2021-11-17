import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'auth.dart';

Future<void> main() async {
  // comment: add it if necessary.
  //  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginProvider()),
      ],
      builder: (context, _) => const TioT(),
    ),
  );
}

class LoginProvider extends ChangeNotifier {
  // LoginProvider: user 상태가 바뀌면 화면을 바꿔주는 State Class
  // home.dart => Login Page || Item Page
  FirebaseAuth auth = FirebaseAuth.instance;

  LoginProvider() {
    init();
  }

  Future<void> init() async {
    auth.userChanges().listen((User? user) {
      if (user == null) {
        _loginState = LoginState.loggedOut;
      } else {
        _loginState = LoginState.loggedIn;
      }
      notifyListeners();
    });
  }

  // 기본 상태는 LoggedOut
  LoginState _loginState = LoginState.loggedOut;
  LoginState get loginState => _loginState;
}
