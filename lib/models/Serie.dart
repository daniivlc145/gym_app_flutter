enum TipoSerie {
  normal,
  calentamiento,
  dropset,
  restpause,
  negativas;

  String get nombre {
    switch (this) {
      case TipoSerie.normal:
        return 'normal';
      case TipoSerie.calentamiento:
        return 'calentamiento';
      case TipoSerie.dropset:
        return 'dropset';
      case TipoSerie.restpause:
        return 'restpause';
      case TipoSerie.negativas:
        return 'negativas';
    }
  }

  // Parsing desde string del JSON → enum
  static TipoSerie fromString(String tipo) {
    return TipoSerie.values.firstWhere(
          (t) => t.nombre.toLowerCase() == tipo.toLowerCase(),
      orElse: () => TipoSerie.normal,
    );
  }
}

class Serie {
  final TipoSerie tipo;
  final List<double> peso;
  final List<int> repeticiones;
  final int numeroSerie;
  final int? rir;
  final bool falloMuscular;
  final String? notas;
  final List<Serie>? subseries; // para dropsets

  Serie({
    required this.tipo,
    required this.peso,
    required this.repeticiones,
    required this.numeroSerie,
    this.rir,
    this.falloMuscular = false,
    this.notas,
    this.subseries,
  });

  Serie copyWith({
    TipoSerie? tipo,
    List<double>? peso,
    List<int>? repeticiones,
    int? numeroSerie,
    int? rir,
    bool? falloMuscular,
    String? notas,
    List<Serie>? subseries,
  }) {
    return Serie(
      tipo: tipo ?? this.tipo,
      peso: peso ?? List<double>.from(this.peso),
      repeticiones: repeticiones ?? List<int>.from(this.repeticiones),
      numeroSerie: numeroSerie ?? this.numeroSerie,
      rir: rir ?? this.rir,
      falloMuscular: falloMuscular ?? this.falloMuscular,
      notas: notas ?? this.notas,
      subseries: subseries ?? this.subseries,
    );
  }

  // ---- FROM JSON ----
  factory Serie.fromJson(Map<String, dynamic> json) {
    TipoSerie tipo = TipoSerie.fromString(json['tipo'] ?? 'normal');

    if (tipo == TipoSerie.dropset && json['series'] is List) {
      // caso dropset
      final sub = (json['series'] as List).map((s) {
        return Serie(
          tipo: TipoSerie.normal,
          numeroSerie: 0,
          peso: [(s['peso'] == "-" ? 0.0 : (s['peso'] as num).toDouble())],
          repeticiones: [(s['reps'] == "-" ? 0 : s['reps'] ?? 0)],
        );
      }).toList();

      return Serie(
        tipo: tipo,
        numeroSerie: json['n_serie'] ?? 0,
        peso: [],
        repeticiones: [],
        subseries: sub,
      );
    } else {
      return Serie(
        tipo: tipo,
        numeroSerie: json['n_serie'] ?? json['numeroSerie'] ?? 0,
        peso: [
          (json['peso'] == "-" ? 0.0 : (json['peso'] as num?)?.toDouble() ?? 0.0)
        ],
        repeticiones: [
          (json['reps'] == "-" ? 0 : (json['reps'] ?? json['repeticiones'] ?? 0))
        ],
        rir: json['rir'],
        falloMuscular: json['falloMuscular'] ?? false,
        notas: json['notas'],
      );
    }
  }

  // ---- TO JSON ----
  Map<String, dynamic> toJson() {
    if (tipo == TipoSerie.dropset && subseries != null) {
      return {
        "tipo": tipo.nombre,
        "n_serie": numeroSerie,
        "series": subseries!.map((s) => {
          "peso": s.peso.isEmpty || s.peso.first == 0 ? "-" : s.peso.first,
          "reps": s.repeticiones.isEmpty || s.repeticiones.first == 0
              ? "-"
              : s.repeticiones.first,
        }).toList(),
      };
    } else {
      return {
        "tipo": tipo.nombre,
        "n_serie": numeroSerie,
        "peso": peso.isEmpty || peso.first == 0 ? "-" : peso.first,
        "reps": repeticiones.isEmpty || repeticiones.first == 0
            ? "-"
            : repeticiones.first,
        "rir": rir,
        "falloMuscular": falloMuscular,
        "notas": notas,
      };
    }
  }
}