import 'package:flutter/material.dart';

class ProfilePages extends StatefulWidget {
  const ProfilePages({super.key});

  @override
  _ProfilePagesState createState() => _ProfilePagesState();
}

class _ProfilePagesState extends State<ProfilePages> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(170, 245, 179, 1),
              Color.fromRGBO(165, 210, 238, 1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(children: [
            Text('Child'),
          ]),
        ),
      )
    );
  }
}
