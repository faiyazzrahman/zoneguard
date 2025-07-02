import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../widgets/bottom_nav.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _mockPosts = [
    {
      'title': 'Suspicious Activity',
      'description': 'Saw someone lurking around parked cars at night',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'imageUrl': 'https://picsum.photos/500/300?random=1',
      'location': {'latitude': 37.7749, 'longitude': -122.4194},
    },
    {
      'title': 'Broken Street Light',
      'description': 'Street light not working on 5th avenue',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'imageUrl': null,
      'location': {'latitude': 37.7759, 'longitude': -122.4184},
    },
    {
      'title': 'Package Theft',
      'description': 'Caught someone stealing packages from porches',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'imageUrl': 'https://picsum.photos/500/300?random=2',
      'location': {'latitude': 37.7769, 'longitude': -122.4174},
    },
  ];

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
    if (index != 0) {
      final routes = ['/map', '/post', '/inbox', '/settings'];
      Navigator.pushReplacementNamed(context, routes[index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 33, 150, 243), // Vibrant blue
              Color.fromARGB(255, 25, 118, 210), // Deep blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Profile Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back,',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'User',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Optional: Add a notification icon or settings shortcut here
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/inbox');
                      },
                      tooltip: 'Notifications',
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Search reports...',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Posts List
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: _buildPostsList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildPostsList() {
    final filtered = _mockPosts.where((post) {
      final title = (post['title'] ?? '').toString().toLowerCase();
      final desc = (post['description'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || desc.contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No reports found',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final post = filtered[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info and timestamp
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent.shade100, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                      radius: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anonymous',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeago.format(post['timestamp']),
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_horiz, color: Colors.grey, size: 26),
                ],
              ),

              const SizedBox(height: 14),

              // Title
              Text(
                post['title'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Colors.blue.shade800,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                post['description'] ?? '',
                style: const TextStyle(fontSize: 16, height: 1.3),
              ),

              const SizedBox(height: 16),

              // Image (if available)
              if (post['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    post['imageUrl'],
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 210,
                        color: Colors.blue.shade50,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 210,
                      color: Colors.grey[300],
                      child: const Center(child: Text("Image load error")),
                    ),
                  ),
                ),

              if (post['imageUrl'] != null) const SizedBox(height: 16),

              // Location (if available)
              if (post['location'] != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Lat: ${post['location']['latitude'].toStringAsFixed(4)}, '
                      'Lng: ${post['location']['longitude'].toStringAsFixed(4)}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
