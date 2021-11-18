import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  late UserCredential credential;

  // google sign in
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await auth.signInWithCredential(credential);
  }

  // Collection 에 User 정보 추가하기
  Future addGoogleUser(UserCredential credential) {
    User? user = credential.user;
    // Write 정보
    FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('toDo');
    return FirebaseFirestore.instance.collection('user').doc(user.uid).set({
      'email': user.email,
      'name': user.displayName,
      'uid': user.uid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/login_bg.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Color(0x33ffffff), BlendMode.dstATop),
        ),
        color: Color(0xffbedff2),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 0, 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Create and manage\nyour time better',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SignInButton(
                Buttons.Google,
                onPressed: () async {
                  credential = await signInWithGoogle();
                  FirebaseFirestore.instance
                      .collection('user')
                      .where('uid', isEqualTo: credential.user!.uid)
                      .get()
                      .then((value) {
                    if (value.docs.isEmpty) {
                      addGoogleUser(credential);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
