import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gym_app/services/supabase_service.dart';
import 'package:gym_app/models/Cadena.dart';

class CadenaGimnasioService {
  final SupabaseClient supabase = SupabaseService().client;

  Future<List<Cadena>> getListaDeCadenasGym() async {
    try {
      final response = await supabase
          .from('cadena_gimnasio')
          .select('pk_cadena_gimnasio, nombre, logo');

      return response.map<Cadena>((data) => Cadena.fromMap(data)).toList();

    }catch(e){
      throw e.toString();
    }
  }
}