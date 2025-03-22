import 'package:flutter/material.dart';

class TrainingScreen extends StatefulWidget {
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entrenamiento'),
      ),
      body: Center(
        child: Text('Pantalla de entrenamiento'),
      ),
    );
  }
}