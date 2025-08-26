import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:gym_app/services/template_service.dart';

import 'current_training_screen.dart';

class TrainingScreen extends StatefulWidget {
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final TemplateService _templateService = TemplateService();
  int numeroPlantillas = 0;
  List<Map<String, dynamic>> rutinas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);

    try {
      final numero = await _templateService.getNumeroPlantillasDeUsuarioActivo();
      List<Map<String, dynamic>> rutinasData = [];
      if (numero > 0) {
        rutinasData = await _templateService.getRutinasDeUsuarioActivo();
      }
      setState(() {
        numeroPlantillas = numero;
        rutinas = rutinasData;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e'), backgroundColor: Colors.red),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _iniciarEntrenamiento({Map<String, dynamic>? rutina}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CurrentTrainingScreen(rutina: rutina),
      ),
    );
  }

  void _mostrarConfirmacion(Map<String, dynamic> rutina) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar"),
        content: Text("¿Quieres iniciar la rutina \"${rutina['nombre']}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _iniciarEntrenamiento(rutina: rutina);
            },
            child: Text("Iniciar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entrenamiento"),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: Platform.isAndroid
          ? const CircularProgressIndicator()
          : const CupertinoActivityIndicator(),)
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Entreno vacío ---
            Text("Inicio Rápido", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _iniciarEntrenamiento(),
              icon: Icon(Icons.flash_on),
              label: Text("Iniciar Entrenamiento Vacío"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 30),

            /// --- Rutinas guardadas ---
            Text("Iniciar Rutina", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            rutinas.isEmpty
                ? Text("No tienes rutinas guardadas.")
                : ExpansionTile(
              title: Text("Seleccionar Rutina"),
              leading: Icon(Icons.fitness_center),
              children: rutinas.map((rutina) {
                return ListTile(
                  title: Text(rutina['nombre']),
                  trailing: Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () => _mostrarConfirmacion(rutina),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}