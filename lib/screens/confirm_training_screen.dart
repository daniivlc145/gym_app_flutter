import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gym_app/screens/social_screen.dart';
import 'package:image_picker/image_picker.dart';

import '../models/Gimnasio.dart';
import '../services/gimnasio_service.dart';

class ConfirmTrainingScreen extends StatefulWidget {
  final Map<String, dynamic> datos;

  const ConfirmTrainingScreen({Key? key, required this.datos}) : super(key: key);

  @override
  _ConfirmTrainingScreenState createState() => _ConfirmTrainingScreenState();
}

class _ConfirmTrainingScreenState extends State<ConfirmTrainingScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  String? _gimnasioSeleccionado;
  List<XFile> _imagenes = [];
  final ImagePicker _picker = ImagePicker();
  Future<List<Gimnasio>>? _gimnasiosFuture;

  late int _duracion;
  late int _numEjercicios;
  late int _numSeries;
  late List<String> _musculos;
  late Map<String, dynamic> _datosCompletos;

  @override
  void initState() {
    super.initState();

    final args = widget.datos;

    _nombreController = TextEditingController(text: args['nombre'] ?? 'Entrenamiento');
    _descripcionController = TextEditingController();
    _duracion = args['duracion'] ?? 0;
    _numEjercicios = args['ejercicios'] ?? 0;
    _numSeries = args['series'] ?? 0;
    _musculos = List<String>.from(args['musculos'] ?? []);
    _datosCompletos = args;

    _gimnasiosFuture = GimnasioService().getGimnasiosDeUsuarioActivo();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _tomarImagen(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _tomarImagen(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _tomarImagen(ImageSource source) async {
    try {
      final XFile? imagen = await _picker.pickImage(source: source);
      if (imagen != null) {
        setState(() {
          _imagenes.add(imagen);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  void _eliminarImagen(int index) {
    setState(() {
      _imagenes.removeAt(index);
    });
  }

  String _formatearDuracion(int minutos) {
    final horas = minutos ~/ 60;
    final mins = minutos % 60;
    if (horas > 0) {
      return '${horas}h ${mins}min';
    }
    return '${mins} min';
  }

  void _guardarEntrenamiento() async {
    if (_gimnasioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un gimnasio')),
      );
      return;
    }

    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor añade un nombre al entrenamiento')),
      );
      return;
    }

    final datosFinales = {
      'nombre'    : _nombreController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'gimnasio'  : _gimnasioSeleccionado,
      'imagenes'  : _imagenes.map((img) => img.path).toList(),
      'duracion'  : _duracion,
      'ejercicios': _numEjercicios,
      'series'    : _numSeries,
      'musculos'  : _musculos,
      'detalles'  : _datosCompletos['detalles'], // 👈 JSON con reps/peso/series
    };

    try {
      // 👉 Aquí llamas a tu servicio real para guardar en la BD
      // await EntrenamientoService().guardarEntrenamiento(datosFinales);

      // 🟢 Mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Entrenamiento guardado correctamente')),
      );

       Navigator.of(context).pushAndRemoveUntil(
         MaterialPageRoute(builder: (_) => SocialScreen()),
         (route) => false,
       );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar entrenamiento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Resumen
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen del entrenamiento',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildResumenItem(Icons.timer, 'Duración', _formatearDuracion(_duracion)),
                    const SizedBox(height: 8),
                    _buildResumenItem(Icons.fitness_center, 'Ejercicios', '$_numEjercicios ejercicios'),
                    const SizedBox(height: 8),
                    _buildResumenItem(Icons.format_list_numbered, 'Series', '$_numSeries series completadas'),
                    if (_musculos.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.accessibility_new, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: _musculos.map((musculo) => Chip(
                                label: Text(musculo, style: const TextStyle(fontSize: 12)),
                                padding: const EdgeInsets.all(4),
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// --- Nombre
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del entrenamiento',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _nombreController.clear(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// --- Descripción
            TextField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            /// --- Selección de gimnasio con FutureBuilder
            FutureBuilder<List<Gimnasio>>(
              future: _gimnasiosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error cargando gimnasios: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No se encontraron gimnasios disponibles");
                }

                final gimnasios = snapshot.data!;

                return DropdownButtonFormField<String>(
                  value: (gimnasios.any((g) => g.pk_gimnasio == _gimnasioSeleccionado))
                      ? _gimnasioSeleccionado
                      : null, // 👈 solo asigna el value si está en la lista
                  decoration: const InputDecoration(
                    labelText: 'Gimnasio',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  hint: const Text('Selecciona un gimnasio'),
                  items: gimnasios.map((gimnasio) {
                    return DropdownMenuItem<String>(
                      value: gimnasio.pk_gimnasio,
                      child: Text(gimnasio.nombre),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _gimnasioSeleccionado = newValue;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            /// --- Sección imágenes
            Text(
              'Fotos del entrenamiento',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _imagenes.length + 1,
              itemBuilder: (context, index) {
                if (index == _imagenes.length) {
                  return InkWell(
                    onTap: _seleccionarImagen,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 32, color: theme.colorScheme.primary),
                            const SizedBox(height: 4),
                            Text('Añadir foto', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_imagenes[index].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => _eliminarImagen(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            /// --- Botón guardar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _guardarEntrenamiento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar entrenamiento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text('$label: ', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}