import 'dart:io';
import 'package:gym_app/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gym_app/services/supabase_service.dart';
import 'package:gym_app/models/Entrenamiento.dart';

/// Extension útil para comparar fechas sin tiempo
extension DateOnlyCompare on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);
}

class TrainingService {
  final SupabaseClient supabase = SupabaseService().client;

  /// Obtener entrenamientos de un usuario concreto
  Future<List<Map<String, dynamic>>> getEntrenamientosUsuario(String pkUsuario) async {
    try {
      final response = await supabase
          .from('entrenamiento')
          .select('''
          pk_entrenamiento,
          nombre,
          descripcion,
          duracion,
          created_at,
          fotos,
          ejercicios,
          usuario:fk_usuario (
            pk_usuario,
            nombre_usuario,
            foto_usuario
          )
        ''')
          .eq('fk_usuario', pkUsuario)
          .order('created_at', ascending: false);

      return (response as List)
          .map((row) => row as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('❌ Error en getEntrenamientosUsuario: $e');
      rethrow;
    }
  }

  /// Obtener entrenamientos del usuario activo
  Future<List<Map<String, dynamic>>> getEntrenamientosUsuarioActivo() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');
      return await getEntrenamientosUsuario(user.id);
    } catch (e) {
      print('❌ Error en getEntrenamientosUsuarioActivo: $e');
      rethrow;
    }
  }

  /// Guardar entrenamiento (con imágenes, historial y PRs)
  Future<void> guardarEntrenamiento(Entrenamiento entrenamiento) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("No hay usuario autenticado");

    try {
      // ---- SUBIR IMÁGENES ----
      final List<String> fotosUrls = [];
      if (entrenamiento.fotos != null && entrenamiento.fotos!.isNotEmpty) {
        for (var file in entrenamiento.fotos!) {
          final fileExt = file.path.split('.').last;
          final fileName = "${DateTime.now().millisecondsSinceEpoch}.$fileExt";
          final filePath = "entrenamientos/${user.id}/$fileName";

          await supabase.storage
              .from('fotos_entrenamiento')
              .upload(filePath, file,
              fileOptions:
              const FileOptions(cacheControl: '3600', upsert: true));

          final publicUrl = supabase.storage
              .from('fotos_entrenamiento')
              .getPublicUrl(filePath);
          fotosUrls.add(publicUrl);
        }
      }

      // ---- ENTRENAMIENTO ----
      final jsonEntrenamiento = {
        'nombre': entrenamiento.nombre,
        'descripcion': entrenamiento.descripcion,
        'duracion': entrenamiento.duracion.inMinutes,
        'fk_usuario': user.id,
        'ejercicios': entrenamiento.ejercicios,
        'fk_gimnasio': entrenamiento.rutinaId,
        'fotos': fotosUrls,
      };

      await supabase.from('entrenamiento').insert(jsonEntrenamiento);

      // ---- HISTORIAL & ULTIMO EJERCICIO ----
      final ejercicios =
          (entrenamiento.ejercicios['ejercicios'] as List?) ?? [];

      for (var ej in ejercicios) {
        final pkEjercicio = ej['pk_ejercicio'];
        final series = (ej['series'] as List?) ?? [];

        // Histórico
        final historial = {
          'fk_usuario': user.id,
          'fk_ejercicio': pkEjercicio,
          'detalles_series': {
            'series': series,
          },
        };
        await supabase.from('historial_ejercicios').insert(historial);

        // ---- Calcular RECORD ----
        double maxPesoNuevo = 0;
        for (var serie in series) {
          double peso = 0.0;

          if (serie['tipo'] == "dropset") {
            // ⚡ Solo el PRIMER PESO de la primera subserie
            if (serie['peso'] is List && (serie['peso'] as List).isNotEmpty) {
              final primeraSubseriePeso = (serie['peso'] as List).first;
              if (primeraSubseriePeso is num) {
                peso = primeraSubseriePeso.toDouble();
              } else if (primeraSubseriePeso is String &&
                  primeraSubseriePeso != "-") {
                peso = double.tryParse(primeraSubseriePeso) ?? 0.0;
              }
            }
          } else {
            // Serie normal → único valor
            if (serie['peso'] is num) {
              peso = (serie['peso'] as num).toDouble();
            } else if (serie['peso'] is String && serie['peso'] != "-") {
              peso = double.tryParse(serie['peso']) ?? 0.0;
            }
          }

          if (peso > maxPesoNuevo) {
            maxPesoNuevo = peso;
          }
        }

        // ---- Comparar con record actual ----
        final recordActualResponse = await supabase
            .from('ultimo_ejercicio_usuario')
            .select('record')
            .eq('fk_usuario', user.id)
            .eq('fk_ejercicio', pkEjercicio)
            .maybeSingle();

        double recordFinal = maxPesoNuevo;
        if (recordActualResponse != null &&
            recordActualResponse['record'] != null) {
          final recordActual =
          (recordActualResponse['record'] as num).toDouble();
          recordFinal =
          maxPesoNuevo > recordActual ? maxPesoNuevo : recordActual;
        }

        // ---- Guardar último ejercicio ----
        final ultimo = {
          'fk_usuario': user.id,
          'fk_ejercicio': pkEjercicio,
          'detalles': ej, // ✅ guardo el ejercicio completo (series incluidas)
          'record': recordFinal, // ✅ normal o primer peso de dropset
        };

        await supabase.from('ultimo_ejercicio_usuario').upsert(
          ultimo,
          onConflict: 'fk_usuario,fk_ejercicio',
        );
      }
    } catch (e) {
      print("❌ Error en guardarEntrenamiento: $e");
      rethrow;
    }
  }

  /// Obtener feed de entrenamientos (de amigos + usuario)
  Future<List<Map<String, dynamic>>> getFeedEntrenamientos({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("No hay usuario autenticado");

      final amigosResponse = await UserService().getAmigos();
      final friendsIds =
      amigosResponse.map((a) => a['pk_usuario'] as String).toList();
      final allUserIds = [...friendsIds, user.id];

      if (allUserIds.isEmpty) return [];

      final response = await supabase
          .from('entrenamiento')
          .select('''
          pk_entrenamiento,
          nombre,
          descripcion,
          duracion,
          created_at,
          fotos,
          ejercicios,
          usuario:fk_usuario (
            pk_usuario,
            nombre_usuario,
            foto_usuario
          )
        ''')
          .inFilter('fk_usuario', allUserIds)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((row) => row as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("❌ Error en getFeedEntrenamientos: $e");
      rethrow;
    }
  }

  /// Obtener afluencia media por gimnasio y día de la semana
  Future<List<Map<String, dynamic>>> getAfluenciaGimnasio({
    required String pkGimnasio,
    required DateTime fechaSeleccionada,
    required String periodo, // "Última semana" | "Último mes" | "Último trimestre"
  }) async {
    try {
      // 1. Determinar rango temporal
      DateTime inicio;
      if (periodo == "Última semana") {
        inicio = fechaSeleccionada.subtract(const Duration(days: 7));
      } else if (periodo == "Último trimestre") {
        inicio = DateTime(
            fechaSeleccionada.year, fechaSeleccionada.month - 3, fechaSeleccionada.day);
      } else {
        inicio = DateTime(
            fechaSeleccionada.year, fechaSeleccionada.month - 1, fechaSeleccionada.day);
      }

      // 2. Día de la semana (Dart: lunes=1,...,domingo=7)
      int weekdaySeleccionado = fechaSeleccionada.weekday;

      // 3. Traer entrenamientos en ese rango
      final response = await supabase
          .from('entrenamiento')
          .select('created_at,duracion')
          .eq('fk_gimnasio', pkGimnasio)
          .gte('created_at', inicio.toIso8601String())
          .lte('created_at', fechaSeleccionada.toIso8601String());

      final entrenamientos = response as List;

      // 4. Calcular start_time
      List<DateTime> sesiones = [];
      for (var row in entrenamientos) {
        final createdAt = DateTime.parse(row['created_at']);
        final duracion = Duration(minutes: row['duracion'] ?? 0);
        final startTime = createdAt.subtract(duracion);

        // Filtrar por día de la semana igual al seleccionado
        if (startTime.weekday == weekdaySeleccionado) {
          sesiones.add(startTime);
        }
      }

      // 5. Agrupar por hora
      Map<int, int> conteoPorHora = {};
      for (var start in sesiones) {
        int hora = start.hour; // 0-23
        conteoPorHora[hora] = (conteoPorHora[hora] ?? 0) + 1;
      }

      // 6. Calcular media (número de semanas en rango)
      int numSemanas =
      ((fechaSeleccionada.difference(inicio).inDays) / 7).ceil().clamp(1, 999);

      List<Map<String, dynamic>> resultado = conteoPorHora.entries.map((entry) {
        return {
          "hora": DateTime(fechaSeleccionada.year, fechaSeleccionada.month,
              fechaSeleccionada.day, entry.key),
          "ocupacion": entry.value / numSemanas
        };
      }).toList();

      // 7. Ordenar por hora
      resultado.sort((a, b) =>
          (a["hora"] as DateTime).hour.compareTo((b["hora"] as DateTime).hour));

      return resultado;
    } catch (e) {
      print("❌ Error en getAfluenciaGimnasio: $e");
      rethrow;
    }
  }
}