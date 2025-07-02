import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../widgets/bottom_nav.dart';
import '../services/supabase_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  String _searchQuery = '';
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _crimeCategories = [];
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;
  bool _hasError = false;
  String? _selectedCrimeType;
  String? _selectedSeverity;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await Future.wait([_loadPosts()]);
  }

  Future<void> _loadPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      print('Error loading posts: $e');
    }
  }

  Future<void> _refreshPosts() async {
    await _loadPosts();
  }

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
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
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          _currentUser?['profile_picture_url'] ??
                              'https://i.pravatar.cc/150?img=12',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back,',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentUser?['name'] ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Refresh button
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _refreshPosts,
                      tooltip: 'Refresh',
                    ),
                    // Notification icon
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
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
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: 'Search reports...',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              // Filter Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        'Crime Type',
                        _selectedCrimeType,
                        _crimeCategories
                            .map((cat) => cat['name'] as String)
                            .toList(),
                        (value) {
                          setState(() => _selectedCrimeType = value);
                          _loadPosts();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        'Severity',
                        _selectedSeverity,
                        ['low', 'medium', 'high', 'critical'],
                        (value) {
                          setState(() => _selectedSeverity = value);
                          _loadPosts();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Posts List
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, -5),
                      ),
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

  Widget _buildFilterDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          dropdownColor: Colors.blue.shade800,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          items: [
            DropdownMenuItem<String>(value: null, child: Text('All ${label}s')),
            ...items.map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load posts',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _refreshPosts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.post_add,
              size: 64,
              color: Colors.blueAccent.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No reports yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to report a crime!',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, '/post'),
              icon: const Icon(Icons.add),
              label: const Text('Create Report'),
            ),
          ],
        ),
      );
    }

    final filtered =
        _posts.where((post) {
          final title = (post['title'] ?? '').toString().toLowerCase();
          final desc = (post['description'] ?? '').toString().toLowerCase();
          final query = _searchQuery.toLowerCase();
          return title.contains(query) || desc.contains(query);
        }).toList();

    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: filtered.length,
        itemBuilder: (context, index) => _buildPostCard(filtered[index]),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    // Parse the created_at timestamp
    DateTime? createdAt;
    try {
      createdAt = DateTime.parse(post['created_at'] ?? '');
    } catch (e) {
      createdAt = DateTime.now();
    }

    final crimeCategory = post['crime_categories'] as Map<String, dynamic>?;
    final user = post['users'] as Map<String, dynamic>?;
    final isAnonymous = post['is_anonymous'] ?? false;

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
                  border: Border.all(
                    color: Colors.blueAccent.shade100,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    isAnonymous
                        ? 'https://i.pravatar.cc/150?img=default'
                        : (user?['profile_picture_url'] ??
                            'https://i.pravatar.cc/150?img=12'),
                  ),
                  radius: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAnonymous
                          ? 'Anonymous'
                          : (user?['name'] ?? 'Unknown User'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          timeago.format(createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        if (crimeCategory != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(
                                crimeCategory['severity'],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              crimeCategory['severity']
                                      ?.toString()
                                      .toUpperCase() ??
                                  'UNKNOWN',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.grey,
                  size: 26,
                ),
                onSelected: (value) async {},
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Text('View Details'),
                      ),
                      const PopupMenuItem(
                        value: 'upvote',
                        child: Text('Upvote'),
                      ),
                      const PopupMenuItem(
                        value: 'downvote',
                        child: Text('Downvote'),
                      ),
                    ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Crime Category
          if (crimeCategory != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                crimeCategory['name'] ?? 'Unknown Category',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Title
          Text(
            post['title'] ?? 'Untitled Report',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Colors.blue.shade800,
            ),
          ),

          const SizedBox(height: 8),

          // Description
          if (post['description'] != null && post['description'].isNotEmpty)
            Text(
              post['description'],
              style: const TextStyle(fontSize: 16, height: 1.3),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

          const SizedBox(height: 16),

          // Evidence Image
          if (post['evidence_image_url'] != null &&
              post['evidence_image_url'].isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                post['evidence_image_url'],
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
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 210,
                      color: Colors.grey[300],
                      child: const Center(child: Text("Image load error")),
                    ),
              ),
            ),

          if (post['evidence_image_url'] != null &&
              post['evidence_image_url'].isNotEmpty)
            const SizedBox(height: 16),

          // Location and metadata
          Row(
            children: [
              if (post['latitude'] != null && post['longitude'] != null) ...[
                const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    post['location_text'] ??
                        'Lat: ${post['latitude'].toStringAsFixed(4)}, Lng: ${post['longitude'].toStringAsFixed(4)}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const Spacer(),
              if (post['view_count'] != null) ...[
                Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${post['view_count']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          ),

          // Incident time
          if (post['incident_time'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Incident: ${_formatIncidentTime(post['incident_time'])}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  String _formatIncidentTime(String? timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(timestamp);
      return timeago.format(dateTime);
    } catch (e) {
      return 'Unknown';
    }
  }
}
