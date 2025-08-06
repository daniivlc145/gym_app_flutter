import 'package:flutter/material.dart';

class ForumSettingsScreen extends StatelessWidget {
  const ForumSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes de Foros'),
      ),
      body: Center(
        child: Text('Aquí van los ajustes del foro.'),
      ),
    );
  }
}
