import 'package:flutter/material.dart';

class TemplatesScreen extends StatefulWidget {
  @override
  _TemplatesScreenState createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plantillas de entrenamiento'),
      ),
      body: Center(
        child: Text('Pantalla de plantillas'),
      ),
    );
  }
}