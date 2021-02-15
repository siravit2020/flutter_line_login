import 'package:flutter/material.dart';
import 'package:flutter_line_login/line.dart';
import 'package:flutter_line_login/line_with_firebase.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: RaisedButton(
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  textColor: Colors.black,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LinePage()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child: SvgPicture.asset('assets/icons/line.svg')),
                      Expanded(
                        flex: 2,
                        child: Text("Login Line"),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                textColor: Colors.black,
                onPressed: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LineWithFirebase()),
                    );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/icons/line.svg'),
                          SvgPicture.asset('assets/icons/firebase.svg'),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Login line with Firebase"),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
