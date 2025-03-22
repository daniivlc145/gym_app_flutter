import 'package:flutter/material.dart';

class ForumsScreen extends StatefulWidget {
  @override
  _ForumsScreenState createState() => _ForumsScreenState();
}

class _ForumsScreenState extends State<ForumsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foros'),
      ),
      body: Center(
        child: Text('Pantalla de foros'),
      ),
    );
  }
}