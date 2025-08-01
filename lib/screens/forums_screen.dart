import 'package:flutter/material.dart';

import '../services/forum_service.dart';
import '../widgets/forum_filter_header.dart';


class ForumsScreen extends StatefulWidget {
  @override
  _ForumsScreenState createState() => _ForumsScreenState();
}

class _ForumsScreenState extends State<ForumsScreen> {

  final ForumService _forumService = ForumService();

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foros'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ForumFilterHeader(
              onChanged: (value) {
                // Cambiar lógica de orden: 'Popular' o 'Último'
                print("Seleccionado: $value");
              },
            ),
          ],
        ),
      ),
    );
  }
}