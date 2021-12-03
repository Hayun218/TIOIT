import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiot/font.dart';

import 'app.dart';
import 'auth.dart';
import 'font_provider.dart';
import 'page_view_state.dart';

Future<void> main() async {
  // comment: add it if necessary.
  //  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences.getInstance().then((pref) {
    var themeFont = pref.getString("ThemeMode");
    if (themeFont == "NanumGothic") {
      activeTheme = nanumGothic;
    } else if (themeFont == "NanumPenScript") {
      activeTheme = nanumPenScript;
    } else if (themeFont == "NotoSansKR") {
      activeTheme = notoSansKR;
    } else if (themeFont == "RobotoMono") {
      activeTheme = robotoMono;
    } else {
      activeTheme = raleway;
    }
    print("가져온 폰트: " + themeFont!);
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => ThemeNotifier(activeTheme)),
          ChangeNotifierProvider(create: (context) => LoginProvider()),
          ChangeNotifierProvider(create: (context) => BottomAppBarProvider()),
        ],
        builder: (context, _) => const TioT(),
      ),
    );
  });
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

class BottomAppBarProvider extends ChangeNotifier {
  void pageFlow(int index) {
    switch (index) {
      case 0:
        _pageState = PageState.dashboard;
        break;
      case 1:
        _pageState = PageState.diary;
        break;
      case 2:
        _pageState = PageState.todo;
        break;
      case 3:
        _pageState = PageState.calendar;
        break;
      case 4:
        _pageState = PageState.badge;
    }
    notifyListeners();
  }

  void signOut() {
    _pageState = PageState.dashboard;
    print("signout");
    notifyListeners();
  }

  PageState _pageState = PageState.dashboard;
  PageState get pageState => _pageState;
}
