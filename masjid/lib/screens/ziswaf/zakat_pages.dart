import 'package:flutter/material.dart';

class DetailZiswafPages extends StatefulWidget {
  const DetailZiswafPages({super.key});

  @override
  _DetailZiswafPagesState createState() => _DetailZiswafPagesState();
}

class _DetailZiswafPagesState extends State<DetailZiswafPages> {

  @override
  Widget build(BuildContext context) {
    late final String title = ModalRoute.of(context)?.settings.arguments as String;
    return Scaffold(
      body: Center(
        child: Text(title),
      ),
    );
  }
}
