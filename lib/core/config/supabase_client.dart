import 'package:supabase_flutter/supabase_flutter.dart';

import 'environment.dart';

// Make Supabase client globally accessible
final SupabaseClient supabase = Supabase.instance.client;

/// Initializes Supabase before app launch (prefer [main.dart] init).
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );
}
