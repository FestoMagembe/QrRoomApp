import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Image(
          image: AssetImage('assets/banner.png'),
          height: 50,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                ClipOval(
                  child: Image(
                    image: AssetImage('assets/team/MANOLO.png'),
                    height: 100,
                    width: 100,
                  ),
                ),
                Expanded(
                  child: Text('Texavier Thobias..\nDeveloper',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
            new Padding(
              padding: const EdgeInsets.only(top: 25.0),
            ),
          ],
        ),
      ),
    );
  }
}

