import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'aboutus.dart';
import 'login.dart';

class UserData extends StatefulWidget {
  @override
  _UserDataState createState() => _UserDataState();
}

class _UserDataState extends State<UserData> with WidgetsBindingObserver {
  DatabaseReference dbRef = FirebaseDatabase.instance.reference();
  late String fName, lName, bDay, address;
  DateTime selectedDate = DateTime.now();

  TextEditingController currPassword = TextEditingController(),
      newPassword = TextEditingController(),
      confPassword = TextEditingController(),
      bDate = TextEditingController(),
      firstName = TextEditingController(),
      lastName = TextEditingController(),
      fieldAddress = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getData();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getData();
    }
  }

  void getData() async {
    var uid = FirebaseAuth.instance.currentUser?.uid;
    fName = (await FirebaseDatabase.instance
            .reference()
            .child("users/" + uid! + "/fname")
            .once())
        .value;
    lName = (await FirebaseDatabase.instance
            .reference()
            .child("users/" + uid + "/lname")
            .once())
        .value;
    bDay = (await FirebaseDatabase.instance
            .reference()
            .child("users/" + uid + "/bDay")
            .once())
        .value;
    address = (await FirebaseDatabase.instance
            .reference()
            .child("users/" + uid + "/address")
            .once())
        .value;

    firstName.text = fName;
    lastName.text = lName;
    bDate.text = bDay;
    fieldAddress.text = address;

    setState(() {
      print('Hello Dear Learner');
    });
  }

  Future<void> editUserInfo(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Edit User Information',
              style: TextStyle(fontSize: 20, fontStyle: FontStyle.normal),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('First Name'),
                  TextField(
                    controller: firstName,
                    decoration: InputDecoration(hintText: "First Name"),
                  ),
                  Text('Last Name'),
                  TextField(
                    controller: lastName,
                    decoration: InputDecoration(hintText: "Last Name"),
                  ),
                  Text('Birthday'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: bDate,
                          decoration: InputDecoration(hintText: "MM/DD/YYYY"),
                        ),
                      ),
                      TextButton(
                        child: Icon(Icons.calendar_today),
                        onPressed: () {
                          _selectDate(context);
                        },
                      ),
                    ],
                  ),
                  Text('Address'),
                  TextField(
                    controller: fieldAddress,
                    decoration: InputDecoration(hintText: "Address"),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel')),
                        TextButton(
                            onPressed: () async {
                              await dbRef
                                  .child(
                                      'users/${FirebaseAuth.instance.currentUser?.uid}')
                                  .update({
                                "name": firstName.text,
                                "name": lastName.text,
                                "bDay": bDate.text,
                                "address": fieldAddress.text
                              });
                              Navigator.pop(context);
                              setState(() {
                                getData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Updated!")));
                              });
                            },
                            child: Text('Save')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1921, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        bDate.text = DateFormat('MM/dd/yyyy').format(selectedDate);
      });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    void logout() {
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(
                height: height * .15,
                child: Center(
                  child: Image(
                    image: AssetImage('assets/banner.png'),
                    height: 50,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  height: height * .60 < 329.0 ? 329.0 : height * .60,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              editUserInfo(context);
                            },
                            child: Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Name:",
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          Text(
                            lName.toString() + ", " + fName.toString(),
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Birthday:",
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          Text(
                            bDay.toString(),
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Address:",
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          Flexible(
                            child: Text(
                              address.toString(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 10.0,
                        color: Colors.white,
                        thickness: 2.0,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Account Information",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Password",
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () async {
                              return showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Change Password',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontStyle: FontStyle.normal),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: currPassword,
                                            decoration: InputDecoration(
                                                hintText: "Current Password"),
                                            obscureText: true,
                                          ),
                                          TextField(
                                            controller: newPassword,
                                            decoration: InputDecoration(
                                                hintText: "New Password"),
                                            obscureText: true,
                                          ),
                                          TextField(
                                            controller: confPassword,
                                            decoration: InputDecoration(
                                                hintText: "Confirm Password"),
                                            obscureText: true,
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Row(
                                              children: [
                                                TextButton(
                                                  child: Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('OK'),
                                                  onPressed: () {
                                                    try {
                                                      FirebaseAuth.instance
                                                          .signInWithEmailAndPassword(
                                                              email: FirebaseAuth
                                                                  .instance
                                                                  .currentUser
                                                                  .email,
                                                              password:
                                                                  currPassword
                                                                      .text);
                                                      if (newPassword.text ==
                                                          confPassword.text) {
                                                        FirebaseAuth.instance
                                                            .currentUser
                                                            .updatePassword(
                                                                newPassword
                                                                    .text);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    "Password Changed!")));
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    "Password not match!")));
                                                      }
                                                    } on FirebaseAuthException catch (e) {
                                                      if (e.code ==
                                                          'wrong-password') {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    "Wrong password!")));
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Text(
                              "Change",
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.cyan),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: logout,
                        child: Text('Log out'),
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).accentColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AboutUs()));
                        },
                        child: Text(
                          "About Us ->",
                          style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.cyan),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
