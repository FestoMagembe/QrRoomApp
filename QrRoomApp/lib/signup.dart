import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late bool exist;
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("users");
  TextEditingController email = TextEditingController(),
      stdNo = TextEditingController(),
      password = TextEditingController(),
      confPass = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    stdNo.dispose();
    password.dispose();
    confPass.dispose();
    super.dispose();
  }

  Future<bool> rootFirebaseIsExists(DatabaseReference dbRef) async {
    DataSnapshot snapshot = await dbRef.once();
    return snapshot != null;
  }

  void signUp() async {
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: new Container(
            height: 100,
            padding: EdgeInsets.all(15),
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                new CircularProgressIndicator(),
                new SizedBox(
                  width: 15,
                ),
                new Text("Signing up..."),
              ],
            ),
          ),
        );
      },
    );

    if (email.text.isNotEmpty &&
        stdNo.text.isNotEmpty &&
        password.text.isNotEmpty &&
        confPass.text.isNotEmpty) {
      if (password.text == confPass.text) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email.text, password: password.text);
          var user = FirebaseAuth.instance.currentUser;
          user?.updateProfile(displayName: stdNo.text);
          dbRef
              .child(FirebaseAuth.instance.currentUser?.uid)
              .set({'userType': "student", 'seat': false, 'email': email.text});
          Navigator.pop(context);
          Navigator.pop(context);
        } on FirebaseAuthException catch (e) {
          Navigator.pop(context);
          if (e.code == 'weak-password') {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("The password provided is too weak")));
          } else if (e.code == 'email-already-in-use') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("The account already exists for that email.")));
          }
        } catch (e) {
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Passwords must match!")));
      }
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please provide all needed information")));
    }
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    var accentColor;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: height * .15),
                    height: height * .80 < 328.0 ? 328.0 : height * .80,
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: email,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            fillColor: Color(0x66B6B6B6),
                            filled: true,
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                decorationColor: Colors.white),
                          ),
                          cursorColor: Theme.of(context).accentColor,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: stdNo,
                          decoration: InputDecoration(
                            hintText: 'Student IDNumber',
                            fillColor: Color(0x66B6B6B6),
                            filled: true,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              decorationColor: Colors.white,
                            ),
                          ),
                          cursorColor: Theme.of(context).accentColor,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: password,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            fillColor: Color(0x66B6B6B6),
                            filled: true,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              decorationColor: Colors.white,
                            ),
                          ),
                          cursorColor: Theme.of(context).accentColor,
                          obscureText: true,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: confPass,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            fillColor: Color(0x66B6B6B6),
                            filled: true,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              decorationColor: Colors.white,
                            ),
                          ),
                          cursorColor: Theme.of(context).accentColor,
                          obscureText: true,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: signUp,
                          child: Text('Sign Up'),
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    child: Text(
                      'Already have an account?\nLog in!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
