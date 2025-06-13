import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://pnaurivuqxoerwgzcnth.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBuYXVyaXZ1cXhvZXJ3Z3pjbnRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk4NDQzMzQsImV4cCI6MjA2NTQyMDMzNH0.oOO2J8xP8ClR3Grb-p5hca4Tfi5z58J2d8fWN7GcKvU',
  );

  runApp(MyApp());
}
