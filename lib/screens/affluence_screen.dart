import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_app/services/training_service.dart';
import 'package:gym_app/services/gimnasio_service.dart';
import 'package:gym_app/models/Gimnasio.dart';

class AffluenceScreen extends StatefulWidget {
  @override
  _AffluenceScreenState createState() => _AffluenceScreenState();
}

class _AffluenceScreenState extends State<AffluenceScreen> {
  String? selectedGimnasio;
  String selectedPeriodo = "Último mes";
  String selectedFechaOption = "Hoy";
  DateTime selectedDate = DateTime.now();
  int chartStartHour = 0;

  List<Map<String, dynamic>> afluenciaData = [];
  List<Gimnasio> gimnasiosUsuario = [];

  final List<String> periodos = ["Última semana", "Último mes", "Último trimestre"];
  final List<String> fechaOptions = ["Hoy", "Mañana", "Seleccionar fecha"];

  @override
  void initState() {
    super.initState();
    _loadGimnasios();
  }

  Future<void> _loadGimnasios() async {
    final gimnasios = await GimnasioService().getGimnasiosDeUsuarioActivo();
    setState(() {
      gimnasiosUsuario = gimnasios;
      if (gimnasios.isNotEmpty) {
        selectedGimnasio = gimnasios.first.pk_gimnasio;
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    if (selectedGimnasio == null) return;

    final data = await TrainingService().getAfluenciaGimnasio(
      pkGimnasio: selectedGimnasio!,
      fechaSeleccionada: selectedDate,
      periodo: selectedPeriodo,
    );
    setState(() => afluenciaData = data);
  }

  /// Semáforo: devuelve color en función de la ocupación relativa
  Color getColorForValue(double value, double max) {
    if (max == 0) return Colors.grey;
    final ratio = value / max;
    if (ratio < 0.4) return Colors.green;
    if (ratio < 0.7) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Afluencia")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Dropdown Gimnasio
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Gimnasio",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: selectedGimnasio,
              onChanged: (val) {
                setState(() => selectedGimnasio = val);
                _loadData();
              },
              items: gimnasiosUsuario
                  .map((g) => DropdownMenuItem(
                value: g.pk_gimnasio,
                child: Text(g.nombre),
              ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// Dropdown Periodo
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Basado en",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: selectedPeriodo,
              onChanged: (val) {
                setState(() => selectedPeriodo = val!);
                _loadData();
              },
              items: periodos
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// Dropdown Fecha de consulta
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Fecha de consulta",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: selectedFechaOption,
              onChanged: (val) async {
                if (val == null) return;

                if (val == "Hoy") {
                  setState(() {
                    selectedFechaOption = val;
                    selectedDate = DateTime.now();
                  });
                  _loadData();
                } else if (val == "Mañana") {
                  setState(() {
                    selectedFechaOption = val;
                    selectedDate = DateTime.now().add(const Duration(days: 1));
                  });
                  _loadData();
                } else if (val == "Seleccionar fecha") {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2027, 12, 31),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedFechaOption = "${picked.toLocal()}".split(' ')[0];
                      selectedDate = picked;
                    });
                    _loadData();
                  }
                }
              },
              items: [
                ...fechaOptions.map(
                      (f) => DropdownMenuItem(value: f, child: Text(f)),
                ),
                if (selectedFechaOption != "Hoy" &&
                    selectedFechaOption != "Mañana" &&
                    selectedFechaOption != "Seleccionar fecha")
                  DropdownMenuItem(
                    value: selectedFechaOption,
                    child: Text(selectedFechaOption),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            /// Gráfica
            Expanded(
              child: Column(
                children: [
                  // Botones cambio de franja
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: chartStartHour == 0
                            ? null
                            : () => setState(() => chartStartHour = 0),
                      ),
                      Text(
                        chartStartHour == 0 ? "Franja: 00h - 12h" : "Franja: 12h - 24h",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: chartStartHour == 12
                            ? null
                            : () => setState(() => chartStartHour = 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Gráfica filtrada
                  Expanded(
                    child: afluenciaData.isEmpty
                        ? const Center(child: Text("No hay datos"))
                        : Builder(
                      builder: (_) {
                        // Construir spots
                        final spots = afluenciaData
                            .map((e) {
                          final hour = (e["hora"] as DateTime).hour.toDouble();
                          final ocupacion = (e["ocupacion"] as num).toDouble();
                          return FlSpot(hour, ocupacion);
                        })
                            .where((spot) =>
                        spot.x >= chartStartHour &&
                            spot.x < chartStartHour + 12)
                            .toList();

                        // Calcular máximo para escalar eje Y
                        final maxOcupacion = spots.isNotEmpty
                            ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b)
                            : 0.0;

                        return LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: (maxOcupacion == 0 ? 10 : maxOcupacion * 1.2),
                            minX: chartStartHour.toDouble(),
                            maxX: (chartStartHour + 12).toDouble(),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: Colors.teal,
                                barWidth: 3,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: getColorForValue(spot.y, maxOcupacion),
                                      strokeWidth: 1.5,
                                      strokeColor: Colors.black,
                                    );
                                  },
                                ),
                              )
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    return Text("${value.toInt()}h",
                                        style: const TextStyle(fontSize: 10));
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: maxOcupacion > 0
                                      ? (maxOcupacion / 5).ceilToDouble()
                                      : 1,
                                  getTitlesWidget: (value, meta) =>
                                      Text("${value.toInt()}",
                                          style: const TextStyle(fontSize: 10)),
                                ),
                              ),
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}