import 'package:flutter/material.dart';
import 'package:gym_app/services/ejercicio_service.dart';

class NombreEjercicioWidget extends StatelessWidget {
  final String pkEjercicio;
  const NombreEjercicioWidget({Key? key, required this.pkEjercicio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: EjercicioService().getNombreEjercicioPorId(pkEjercicio),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('• Cargando...', style: Theme.of(context).textTheme.bodyMedium);
        } else if (snapshot.hasError) {
          return Text('• (error)', style: Theme.of(context).textTheme.bodyMedium);
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('• (desconocido)', style: Theme.of(context).textTheme.bodyMedium);
        } else {
          return Text('• ${snapshot.data}', style: Theme.of(context).textTheme.bodyMedium);
        }
      },
    );
  }
}