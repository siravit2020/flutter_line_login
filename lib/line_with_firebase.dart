import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:jwt_decoder/jwt_decoder.dart';

class LineWithFirebase extends StatefulWidget {
  LineWithFirebase({Key key}) : super(key: key);

  @override
  _LineWithFirebase createState() => _LineWithFirebase();
}

class _LineWithFirebase extends State<LineWithFirebase> {
  String id = '';
  String name = '';
  String avatar = '';
  bool visible = false;
  String link = '';
  FirebaseAuth auth = FirebaseAuth.instance;

  void getHttp(Map<String, dynamic> decodedToken, String access) async {
    var url =
        'https://asia-northeast1-linelogin-77938.cloudfunctions.net/createCustomToken';
    var response = await http.post(url, body: {
      'access_token': access,
      'email': decodedToken['email'],
      'name': decodedToken['name'],
      'picture': decodedToken['picture'],
      'id': decodedToken['sub'],
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    Map<String, dynamic> re = jsonDecode(response.body);
    print(re['firebase_token']);
    var result = await auth.signInWithCustomToken(re['firebase_token']);
    print(result);
    print(auth.currentUser.email);
  }

  void login() async {
    try {
      final result =
          await LineSDK.instance.login(scopes: ["profile", "openid", "email"]);

      setState(() {
        id = result.userProfile.userId;
        name = result.userProfile.displayName;
        avatar = result.userProfile.pictureUrl;
        print(result.data);
        print(result.data['accessToken']['id_token']);

        String yourToken = result.data['accessToken']['id_token'];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(yourToken);
        print(decodedToken);
        getHttp(decodedToken, result.data['accessToken']['access_token']);
        visible = true;
        setState(() {});
      });
    } on PlatformException catch (e) {
      // Error handling.
      print(e);
    }
  }

  void check() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        print(currentUser);
        id = currentUser.uid;
        name = currentUser.displayName;
        avatar = currentUser.photoURL;

        visible = true;
        setState(() {});
      } else {
        print('empty');
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void logoutFirebase() async {
    FirebaseAuth.instance.signOut().then((value) {
      logoutLine();
    });
  }

  void logoutLine() async {
    try {
      await LineSDK.instance.logout();
      print('Logout success');
      visible = false;
      setState(() {});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  @override
  void initState() {
    super.initState();
    check();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff00b900),
        title: Text('Login line with firebase'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/icons/firebase.svg'),
          (visible)
              ? Column(
                  children: [
                    ClipOval(
                      child: Image.network(
                        '$avatar',
                        height: 100,
                        width: 100,
                      ),
                    ),
                    Text(
                      '$id',
                    ),
                    Text(
                      '$name',
                    ),
                  ],
                )
              : SizedBox(),
          RaisedButton(
            color: Color(0xff00b900),
            textColor: Colors.white,
            onPressed: () {
              visible ? logoutFirebase() : login();
            },
            child: Text(visible ? 'ออกจากระบบ' : 'เข้าสู่ระบบด้วย Line'),
          )
        ],
      )),
    );
  }
}
