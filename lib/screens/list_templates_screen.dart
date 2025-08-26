import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/services/template_service.dart';
import 'package:gym_app/screens/rutina_screen.dart';
import 'package:gym_app/widgets/rutina_card.dart';

class ListTemplatesScreen extends StatefulWidget {
  @override
  _ListTemplatesScreenState createState() => _ListTemplatesScreenState();
}

class _ListTemplatesScreenState extends State<ListTemplatesScreen> {
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

  Future<void> _eliminarRutina(String rutinaId) async {
    try {
      await _templateService.eliminarRutina(rutinaId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rutina eliminada correctamente'), backgroundColor: Colors.green),
      );
      _cargarDatos();
    } catch (e) {
      print('Error al eliminar rutina: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar rutina: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _mostrarDialogoConfirmacion(String rutinaId, String nombreRutina) async {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar rutina', style: theme.textTheme.titleMedium),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres eliminar la rutina "$nombreRutina"?', style: theme.textTheme.bodyLarge),
                Text('Esta acción no se puede deshacer.', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: theme.textTheme.bodyLarge),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Eliminar', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error)),
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarRutina(rutinaId);
              },
            ),
          ],
        );
      },
    );
  }

  void _navegarAEditarRutina(String rutinaId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RutinaScreen(rutinaId: rutinaId)),
    ).then((_) => _cargarDatos());
  }

  void _navegarAAddRutina() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RutinaScreen()),
    ).then((_) => _cargarDatos());
  }

  void _navegarAEntrenamiento(String rutinaId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Entrenamiento en marcha!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Plantillas de entrenamiento'),
      ),
      body: isLoading
          ? Center(child: Platform.isAndroid
          ? const CircularProgressIndicator()
          : const CupertinoActivityIndicator(),)
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'En uso: $numeroPlantillas/7',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: numeroPlantillas == 0
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: theme.colorScheme.secondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aún no tienes rutinas',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Crea tu primera rutina para comenzar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('CREAR RUTINA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _navegarAAddRutina,
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: rutinas.length,
              itemBuilder: (context, index) {
                final rutina = rutinas[index];
                return CardRutina(
                  rutina: rutina,
                  onEditar: _navegarAEditarRutina,
                  onEliminar: _mostrarDialogoConfirmacion,
                  onEntrenar: _navegarAEntrenamiento,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: numeroPlantillas > 0 && numeroPlantillas < 7
          ? FloatingActionButton(
        onPressed: _navegarAAddRutina,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: Icon(Icons.add),
        tooltip: 'Añadir rutina',
      )
          : null,
    );
  }
}