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

  Serie({
    required this.tipo,
    required this.peso,
    required this.repeticiones,
    required this.numeroSerie,
    this.rir,
    this.falloMuscular = false,
    this.notas,
  });

  Serie copyWith({
    TipoSerie? tipo,
    List<double>? peso,
    List<int>? repeticiones,
    int? numeroSerie,
    int? rir,
    bool? falloMuscular,
    String? notas,
  }) {
    return Serie(
      tipo: tipo ?? this.tipo,
      peso: peso ?? List<double>.from(this.peso),
      repeticiones: repeticiones ?? List<int>.from(this.repeticiones),
      numeroSerie: numeroSerie ?? this.numeroSerie,
      rir: rir ?? this.rir,
      falloMuscular: falloMuscular ?? this.falloMuscular,
      notas: notas ?? this.notas,
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
      if (json['repeticiones'] is List) {
        return (json['repeticiones'] as List)
            .map((r) => r is int ? r : int.tryParse(r.toString()) ?? 0)
            .toList();
      } else if (json['repeticiones'] is int) {
        return [json['repeticiones']];
      } else if (json['repeticiones'] is String) {
        return [int.tryParse(json['repeticiones']) ?? 0];
      }
      return [];
    }

    return Serie(
      tipo: TipoSerie.fromString(json['tipo'] ?? 'normal'),
      peso: procesarPeso(),
      repeticiones: procesarRepeticiones(),
      numeroSerie: json['numeroSerie'] ?? 0,
      rir: json['rir'],
      falloMuscular: json['falloMuscular'] ?? false,
      notas: json['notas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo.toString().split('.').last,
      'peso': peso,
      'repeticiones': repeticiones,
      'numeroSerie': numeroSerie,
      'rir': rir,
      'falloMuscular': falloMuscular,
      'notas': notas,
    };
  }
}