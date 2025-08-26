enum TipoSerie {
  normal,
  calentamiento,
  dropset,
  restpause,
  negativas;

  String get nombre {
    switch (this) {
      case TipoSerie.normal:
        return 'Normal';
      case TipoSerie.calentamiento:
        return 'Calentamiento';
      case TipoSerie.dropset:
        return 'Drop Set';
      case TipoSerie.restpause:
        return 'Rest-Pause';
      case TipoSerie.negativas:
        return 'Negativas';
    }
  }

  static TipoSerie fromString(String tipo) {
    return TipoSerie.values.firstWhere(
          (t) => t.toString().split('.').last == tipo,
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
  final List<Serie>? subseries;

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

  factory Serie.fromJson(Map<String, dynamic> json) {
    List<double> procesarPeso() {
      if (json['peso'] is List) {
        return (json['peso'] as List)
            .map((p) => p is double ? p : double.tryParse(p.toString()) ?? 0.0)
            .toList();
      } else if (json['peso'] is double || json['peso'] is int) {
        return [json['peso'].toDouble()];
      } else if (json['peso'] is String) {
        return [double.tryParse(json['peso']) ?? 0.0];
      }
      return [];
    }

    List<int> procesarRepeticiones() {
      if (json['repeticiones'] != null) {
        if (json['repeticiones'] is List) {
          return (json['repeticiones'] as List)
              .map((r) => r is int ? r : int.tryParse(r.toString()) ?? 0)
              .toList();
        } else if (json['repeticiones'] is int) {
          return [json['repeticiones']];
        } else if (json['repeticiones'] is String) {
          return [int.tryParse(json['repeticiones']) ?? 0];
        }
      } else if (json['reps'] != null) {    // <- AÑADE ESTO
        if (json['reps'] is List) {
          return (json['reps'] as List)
              .map((r) => r is int ? r : int.tryParse(r.toString()) ?? 0)
              .toList();
        } else if (json['reps'] is int) {
          return [json['reps']];
        } else if (json['reps'] is String) {
          return [int.tryParse(json['reps']) ?? 0];
        }
      }
      return [];
    }

    List<double> procesarPesoV2() {
      if (json['peso'] != null) {
        if (json['peso'] is List) {
          return (json['peso'] as List)
              .map((p) => p is double ? p : double.tryParse(p.toString()) ?? 0.0)
              .toList();
        } else if (json['peso'] is double || json['peso'] is int) {
          return [json['peso'].toDouble()];
        } else if (json['peso'] is String) {
          return [double.tryParse(json['peso']) ?? 0.0];
        }
      } else if (json['peso'] == null && json['series'] != null && json['tipo'] == 'dropset') {
        // Caso de dropset: múltiples pesos internos
        // Pero aquí necesitarías lógica aparte para sub-series en dropset (ver abajo)
        return [];
      }
      return [];
    }

    List<Serie>? subseries;
    if (json['tipo'] == 'dropset' && json['series'] is List) {
      subseries = (json['series'] as List)
          .map((s) => Serie.fromJson({
        // Aquí normalmente los subseries no traen ni tipo, ni n_serie;
        // Solo repeticiones y peso
        'tipo': 'normal',
        'peso': s['peso'],
        'repeticiones': s['reps'] ?? s['repeticiones'],
        'numeroSerie': 0, // o algún valor si necesitas
      }))
          .toList();
    }

    return Serie(
      tipo: TipoSerie.fromString(json['tipo'] ?? 'normal'),
      peso: procesarPesoV2(), // tu campo en JSON es 'peso'
      repeticiones: procesarRepeticiones(),
      numeroSerie: json['numeroSerie'] ?? json['n_serie'] ?? 0,
      rir: json['rir'],
      falloMuscular: json['falloMuscular'] ?? false,
      notas: json['notas'],
      subseries: subseries,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'tipo': tipo.toString().split('.').last,
      'peso': peso,
      'repeticiones': repeticiones,
      'numeroSerie': numeroSerie,
      'rir': rir,
      'falloMuscular': falloMuscular,
      'notas': notas,
    };
    if (subseries != null) {
      map['subseries'] = subseries!.map((s) => s.toJson()).toList();
    }
    return map;
  }
}