import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class ConfirmData extends StatefulWidget {
  @override
  _ConfirmDataState createState() => _ConfirmDataState();
}

class _ConfirmDataState extends State<ConfirmData> {
  DatabaseReference dbRef = FirebaseDatabase.instance.reference();
  TextEditingController code = new TextEditingController();
  bool visible = false;
  String area = " ", time = " ", date = " ";
  DateTime now;

  void scan() async {
    var status = await Permission.camera.status;
    print(status.toString());
    if (status.isGranted || status.isLimited) {
      await Permission.camera.request();
      String barcode = await scanner.scan();
      if (barcode == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Invalid QR Code!")));
      } else {
        code.text = barcode;
      }
    } else {
      await Permission.camera.request();
      status = await Permission.camera.status;
      if (status.isGranted || status.isLimited) {
        await Permission.camera.request();
        String barcode = await scanner.scan();
        if (barcode == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Invalid QR Code!")));
        } else {
          code.text = barcode;
        }
      } else
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Can\'t Open Camera, Camera Permission Denied!')));
    }
  }

  void record() async {
    int space = int.parse((await dbRef.child('admin/parkingSpace').once()).value.toString());
    code.text = code.text.toUpperCase();
    if(code.text == "ARELLANO_ENTRANCE") {
      if(space > 0) {
        dbRef.child('admin').update({'parkingSpace': space-1});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('There are no more space left!')));
      }
    }
    else if(code.text == "NAVEL_EXIT") {
      dbRef.child('admin').update({'parkingSpace': space+1});
    }
    var uid = FirebaseAuth.instance.currentUser.uid;
    String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    dbRef.child("users/" + uid + "/history/" + formattedDate).set({
      'stdNo': FirebaseAuth.instance.currentUser.displayName,
      'uid': FirebaseAuth.instance.currentUser.uid,
      'room': code.text,
      'date': date,
      'time': time
    });
    dbRef.child("roomHistory/${code.text.toUpperCase()}/$formattedDate").set({
      'stdNo': FirebaseAuth.instance.currentUser.displayName,
      'uid': FirebaseAuth.instance.currentUser.uid,
      'room': code.text,
      'date': date,
      'time': time
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recorded!')));
    Navigator.pop(context);
  }

  void confirmData() async {
    if (await verify()) {
      setState(() {
        area = code.text;
        now = DateTime.now();
        // time = TimeOfDay.now().format(context).toString();
        time = DateFormat('kk:mm:ss').format(now);
        date = DateFormat('yyyy-MM-dd').format(now);
        visible = true;
      });
    }
    else if(code.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter required data!')));
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Room Code not found!')));
    }
  }

  Future<bool> verify() async {
    if(code.text.isNotEmpty) {
      if(code.text == "ARELLANO_ENTRANCE" || code.text == "NAVEL_EXIT")
        return true;
      var rooms = (await dbRef.child("room").once()).value;
      for (String room in rooms.keys) {
        if (room == code.text) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Image(
            image: AssetImage('assets/banner.png'),
            height: 50,
          ),
        ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 100,
                              height: 140,
                              child: InkWell(
                                onTap: scan,
                                child: Card(
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                      Divider(height: 20),
                                      Expanded(flex: 1, child: Text("Scan")),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            VerticalDivider(
                              width: 10.0,
                              color: Colors.white,
                              thickness: 1.0,
                            ),
                            SizedBox(
                              width: width - 140,
                              height: 140,
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: <Widget>[
                                      Text('Enter Room Code:'),
                                      TextField(
                                        decoration: InputDecoration(
                                            hintText: 'ABC 123'),
                                        controller: code,
                                      ),
                                      ElevatedButton(
                                          onPressed: confirmData,
                                          child: Text('Submit')),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 10.0,
                    color: Colors.white,
                    thickness: 1.0,
                  ),
                  Visibility(
                    visible: visible,
                    child: Container(
                      //ConfirmData
                      height: height * .65 < 300.0 ? 300.0 : height * .65,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Confirm Data",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Area:",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                area.toString(),
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
                                "Time:",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                time.toString(),
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
                                "Date:",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                date.toString(),
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 250,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 25.0, right: 25.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Decline'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).accentColor,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: record,
                                  child: Text('Confirm'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
