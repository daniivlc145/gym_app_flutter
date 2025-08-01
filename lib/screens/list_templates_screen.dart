import 'package:flutter/material.dart';
import 'package:gym_app/services/template_service.dart';

class TemplatesScreen extends StatefulWidget {
  @override
  _TemplatesScreenState createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
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
    setState(() {
      isLoading = true;
    });

    try {
      // Cargar número de plantillas
      final numero = await _templateService.getNumeroPlantillasDeUsuarioActivo();

      // Cargar las rutinas si hay alguna
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
          SnackBar(content: Text('Error al cargar datos: $e'), backgroundColor: Colors.red)
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Función para eliminar una rutina
  Future<void> _eliminarRutina(String rutinaId) async {
    try {
      await _templateService.eliminarRutina(rutinaId);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rutina eliminada correctamente'), backgroundColor: Colors.green)
      );
      _cargarDatos(); // Recargar datos después de eliminar
    } catch (e) {
      print('Error al eliminar rutina: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar rutina: $e'), backgroundColor: Colors.red)
      );
    }
  }

  // Función para mostrar el diálogo de confirmación
  Future<void> _mostrarDialogoConfirmacion(String rutinaId, String nombreRutina) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar rutina'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres eliminar la rutina "$nombreRutina"?'),
                Text('Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
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

  // Función para navegar a la pantalla de edición
  void _navegarAEditarRutina(String rutinaId) {
    // Aquí implementarías la navegación a la pantalla de edición
    // Por ejemplo:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => EditarRutinaScreen(rutinaId: rutinaId)),
    // ).then((_) => _cargarDatos());

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navegando a editar rutina ID: $rutinaId'))
    );
  }

  // Función para navegar a la pantalla de añadir rutina
  void _navegarAAddRutina() {
    // Aquí implementarías la navegación a la pantalla de añadir rutina
    // Por ejemplo:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => AddRutinaScreen()),
    // ).then((_) => _cargarDatos());

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navegando a añadir rutina'))
    );
  }

  // Función para navegar a la pantalla de entrenamiento
  void _navegarAEntrenamiento(String rutinaId) {

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entrenamiento en marcha!'))
    );
  }

  // Widget para mostrar una tarjeta de rutina
  Widget _construirTarjetaRutina(Map<String, dynamic> rutina) {
    final String rutinaId = rutina['pk_rutina'];
    final String nombreRutina = rutina['nombre'];
    final ejercicios = rutina['ejercicios'];

    // Extraer nombres de ejercicios para el resumen
    List<String> nombresEjercicios = [];
    if (ejercicios is Map) {
      ejercicios.forEach((key, value) {
        if (value is Map && value.containsKey('nombre')) {
          nombresEjercicios.add(value['nombre']);
        }
      });
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nombreRutina,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _navegarAEditarRutina(rutinaId),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _mostrarDialogoConfirmacion(rutinaId, nombreRutina),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Ejercicios:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            nombresEjercicios.isEmpty
                ? Text('No hay ejercicios en esta rutina', style: TextStyle(fontStyle: FontStyle.italic))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: nombresEjercicios
                  .take(3) // Mostrar solo los primeros 3 ejercicios
                  .map((nombre) => Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text('• $nombre'),
              ))
                  .toList(),
            ),
            if (nombresEjercicios.length > 3)
              Text('... y ${nombresEjercicios.length - 3} más', style: TextStyle(fontStyle: FontStyle.italic)),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.fitness_center),
                label: Text('INICIAR ENTRENAMIENTO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1ABC9C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _navegarAEntrenamiento(rutinaId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plantillas de entrenamiento'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF1ABC9C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'En uso: $numeroPlantillas/7',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
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
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aún no tienes rutinas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Crea tu primera rutina para comenzar',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('CREAR RUTINA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1ABC9C),
                      foregroundColor: Colors.white,
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
                return _construirTarjetaRutina(rutinas[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: numeroPlantillas > 0 && numeroPlantillas < 7
          ? FloatingActionButton(
        onPressed: _navegarAAddRutina,
        backgroundColor: Color(0xFF1ABC9C),
        child: Icon(Icons.add),
        tooltip: 'Añadir rutina',
      )
          : null,
    );
  }
}