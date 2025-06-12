import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://erqphzgclgopxghuzmfq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVycXBoemdjbGdvcHhnaHV6bWZxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg5NDc3ODQsImV4cCI6MjA2NDUyMzc4NH0.dwsCQgayXSaP5Z5SJeRa4UT6MgmMXJzOBggt_uNJUyk',
  );

  runApp(MyApp());
}
