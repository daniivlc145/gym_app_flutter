import 'package:flutter/material.dart';

class AffluenceScreen extends StatefulWidget {
  @override
  _AffluenceScreenState createState() => _AffluenceScreenState();
}

class _AffluenceScreenState extends State<AffluenceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Afluencia'),
      ),
      body: Center(
        child: Text('Pantalla de Afluencia'),
      ),
    );
  }
}