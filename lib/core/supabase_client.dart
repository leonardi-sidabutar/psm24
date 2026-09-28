import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static SupabaseClient get client => Supabase.instance.client;
}