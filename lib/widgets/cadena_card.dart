import 'package:flutter/material.dart';

class CadenaCard extends StatelessWidget {
  final String id;
  final String nombre;
  final String logo;
  final bool isSelected;
  final VoidCallback onTap;

  CadenaCard({
    required this.id,
    required this.nombre,
    required this.logo,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected ? Colors.greenAccent : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(logo, height: 50, width: 50),
            SizedBox(height: 10),
            Text(nombre, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}