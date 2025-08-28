import 'package:flutter/material.dart';
import 'package:gym_app/widgets/nombre_ejercicio_widget.dart';

class TrainingFeedCard extends StatefulWidget {
  final Map<String, dynamic> trainingData;
  final VoidCallback? onUserTap;

  const TrainingFeedCard({
    Key? key,
    required this.trainingData,
    this.onUserTap,
  }) : super(key: key);

  @override
  _TrainingFeedCardState createState() => _TrainingFeedCardState();
}

class _TrainingFeedCardState extends State<TrainingFeedCard> {
  bool verMas = false;

  String _abreviacionTipoFromString(String tipo) {
    switch (tipo.toLowerCase()) {
      case "normal":
        return "N";
      case "calentamiento":
        return "C";
      case "dropset":
        return "DS";
      case "restpause":
        return "RP";
      case "negativas":
        return "NE";
      default:
        return tipo; // fallback por si viene algo raro
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainingData = widget.trainingData;
    final usuario = trainingData['usuario'];
    final fotos = (trainingData['fotos'] as List?) ?? [];
    final ejercicios = (trainingData['ejercicios'] as Map?)?['ejercicios'] ?? [];
    final createdAt = trainingData['created_at'] != null
        ? DateTime.tryParse(trainingData['created_at'])
        : null;

    // Si no está expandido, limitamos a 3
    final ejerciciosMostrados =
    verMas ? ejercicios : (ejercicios.take(3).toList());

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Header con avatar + nombre + fecha ----
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: widget.onUserTap,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: usuario['foto_usuario'] != null
                        ? NetworkImage(usuario['foto_usuario'])
                        : null,
                    child: usuario['foto_usuario'] == null
                        ? Icon(Icons.person)
                        :null,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onUserTap,
                    child: Text(
                      usuario['nombre_usuario'] ?? 'Usuario',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                if (createdAt != null)
                  Text(
                    "${createdAt.day.toString().padLeft(2,'0')}/"
                        "${createdAt.month.toString().padLeft(2,'0')}/"
                        "${createdAt.year}",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
            SizedBox(height: 10),

            // ---- Nombre del entrenamiento ----
            Text(
              trainingData['nombre'] ?? '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (trainingData['descripcion'] != null &&
                trainingData['descripcion'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  trainingData['descripcion'],
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),

            // ---- Duración ----
            if (trainingData['duracion'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  "Duración: ${trainingData['duracion']} min",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),

            SizedBox(height: 10),

            // ---- Fotos ----
            if (fotos.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: fotos.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        fotos[index],
                        fit: BoxFit.cover,
                        width: 250,
                      ),
                    );
                  },
                ),
              ),

            SizedBox(height: 12),

            // ---- Lista de ejercicios ----
            if (ejercicios.isNotEmpty) ...[
              Text("Ejercicios:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 6),
              Column(
                children: [
                  for (var ej in ejerciciosMostrados)
                    ExpansionTile(
                      leading: Icon(Icons.fitness_center,
                          size: 20, color: Colors.grey[600]),
                      title: NombreEjercicioWidget(
                        pkEjercicio: ej['pk_ejercicio'].toString(),
                      ),
                      children: [
                        if (ej['series'] != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, bottom: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0; i < ej['series'].length; i++)
                                  Text(
                                    "${_abreviacionTipoFromString(ej['series'][i]['tipo'])}: "
                                        "${ej['series'][i]['reps']} reps x ${ej['series'][i]['peso']} kg",
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  if (ejercicios.length > 3)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          verMas = !verMas;
                        });
                      },
                      child: Text(verMas ? "Ver menos" : "Ver más"),
                    ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}