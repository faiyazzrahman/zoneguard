import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int _currentIndex = 1;
  String _searchQuery = '';

  void _onTabSelected(int index) {
    if (index == _currentIndex) return; // Avoid reloading same page
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        // Already on Map page
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/post');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/inbox');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

 @override
Widget build(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  final LinearGradient backgroundGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 104, 169, 255),
    Color.fromARGB(255, 55, 104, 114),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      title: const Text(
        'Map',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
    ),
    body: Container(
      decoration: BoxDecoration(gradient: backgroundGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔍 Search Bar
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800]?.withOpacity(0.3) : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: TextStyle(color: isDark ? Colors.white : Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.white70),
                    prefixIcon: Icon(Icons.search, color: isDark ? Colors.white70 : Colors.white70),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🗺️ Map Card
              Expanded(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  color: isDark ? Colors.grey[900] : Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map, size: 80, color: isDark ? Colors.white54 : Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Map Placeholder',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crime locations will be shown here',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white54 : Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: BottomNav(
      currentIndex: _currentIndex,
      onTabSelected: _onTabSelected,
    ),
  );
}
}