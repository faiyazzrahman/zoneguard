import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://qynbyqukozsopwbenoyt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5bmJ5cXVrb3pzb3B3YmVub3l0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExMTc5NjQsImV4cCI6MjA2NjY5Mzk2NH0.mGw6Xkj4ma4u2FDPSdUU0yj2bxjEI7QKn_USfM07-XM',
  );

  runApp(MyApp());
}
