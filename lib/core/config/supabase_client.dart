import 'package:supabase_flutter/supabase_flutter.dart';

// Make Supabase client globally accessible
final SupabaseClient supabase = Supabase.instance.client;

/// Initializes Supabase before app launch
Future<void> initSupabase() async {
  await Supabase.initialize(
    url:
        'https://YOUR_PROJECT_URL.supabase.co', // replace with your project URL
    anonKey: 'YOUR_ANON_KEY', // replace with your anon/public API key
  );
}
