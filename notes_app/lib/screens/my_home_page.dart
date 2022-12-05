import 'package:flutter/material.dart';

import '../values.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentPinkColor,
      appBar: AppBar(
          title: Center(
              child: Text(
            "My NoteBooks",
            style: TextStyle(color: plumColor),
          )),
          elevation: 0,
          backgroundColor: accentPinkColor,
          leading: Icon(
            Icons.menu,
            color: pinkColor,
          ),
          actions: [
            Icon(
              Icons.add,
              color: pinkColor,
            ),
            SizedBox(
              width: 10,
            )
          ]),
      body: Container(
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
