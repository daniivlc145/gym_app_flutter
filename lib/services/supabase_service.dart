import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://yomjlscxsdqswdtogntm.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvbWpsc2N4c2Rxc3dkdG9nbnRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA4NDkwNDksImV4cCI6MjA1NjQyNTA0OX0.wB8OBgNjyfWyLtxpM2zqlDO_vqr8HrmtIWIfnfvanyk',
    );
  }

  SupabaseClient get client => Supabase.instance.client;
}