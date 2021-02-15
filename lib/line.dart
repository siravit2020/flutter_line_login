import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class LinePage extends StatefulWidget {
  LinePage({Key key}) : super(key: key);

  @override
  _LinePageState createState() => _LinePageState();
}

class _LinePageState extends State<LinePage> {
  String id = '';
  String name = '';
  String avatar = '';
  bool visible = false;

  void login() async {
    try {
      final result =
          await LineSDK.instance.login(scopes: ["profile", "openid", "email"]);

      setState(() {
        id = result.userProfile.userId;
        name = result.userProfile.displayName;
        avatar = result.userProfile.pictureUrl;
        print(result.idTokenNonce);
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
      final currentUser = await LineSDK.instance.currentAccessToken;
      if (currentUser != null) {
        print(currentUser.data);
        final result = await LineSDK.instance.getProfile();
        id = result.userId;
        name = result.displayName;
        avatar = result.pictureUrl;

        visible = true;
        setState(() {});
      } else {
        print('empty');
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void logout() async {
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
    return SafeArea(
      child: Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                visible ? logout() : login();
              },
              child: Text(visible ? 'ออกจากระบบ' : 'เข้าสู่ระบบด้วย Line'),
            )
          ],
        )),
      ),
    );
  }
}
