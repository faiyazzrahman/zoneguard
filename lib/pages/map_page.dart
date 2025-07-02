import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../widgets/bottom_nav.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  int _currentIndex = 1;
  String _searchQuery = '';
  final MapController _mapController = MapController();
  final Location _location = Location();
  LatLng? _currentLocation;
  bool _isLoading = false;
  String _selectedMapStyle = 'standard';
  bool _showCrimeLocations = true;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Sample crime data - replace with your actual data source
  final List<Map<String, dynamic>> _crimeLocations = [
    {
      'id': '1',
      'location': LatLng(23.8103, 90.4125),
      'type': 'Theft',
      'severity': 'medium',
      'time': '2 hours ago',
      'description': 'Mobile phone theft reported',
    },
    {
      'id': '2',
      'location': LatLng(23.7279, 90.4107),
      'type': 'Robbery',
      'severity': 'high',
      'time': '5 hours ago',
      'description': 'Armed robbery at local shop',
    },
    {
      'id': '3',
      'location': LatLng(23.7461, 90.3742),
      'type': 'Vandalism',
      'severity': 'low',
      'time': '1 day ago',
      'description': 'Property damage reported',
    },
    {
      'id': '4',
      'location': LatLng(23.8041, 90.4152),
      'type': 'Assault',
      'severity': 'high',
      'time': '3 hours ago',
      'description': 'Physical assault incident',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
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

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _isLoading = false);
        return;
      }
    }

    try {
      LocationData locationData = await _location.getLocation();
      setState(() {
        _currentLocation = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
        _isLoading = false;
      });

      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, 15.0);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to get location: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Color _getCrimeColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  IconData _getCrimeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'theft':
        return Icons.shopping_bag;
      case 'robbery':
        return Icons.dangerous;
      case 'vandalism':
        return Icons.broken_image;
      case 'assault':
        return Icons.warning;
      default:
        return Icons.report;
    }
  }

  void _showCrimeDetails(Map<String, dynamic> crime) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getCrimeColor(
                          crime['severity'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCrimeIcon(crime['type']),
                        color: _getCrimeColor(crime['severity']),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crime['type'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            crime['time'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getCrimeColor(crime['severity']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        crime['severity'].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  crime['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _mapController.move(crime['location'], 18.0);
                        },
                        icon: const Icon(Icons.zoom_in),
                        label: const Text('Zoom to Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Add report functionality here
                        },
                        icon: const Icon(Icons.report),
                        label: const Text('Report'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Add current location marker
    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 60,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ),
      );
    }

    // Add crime location markers
    if (_showCrimeLocations) {
      for (int i = 0; i < _crimeLocations.length; i++) {
        var crime = _crimeLocations[i];
        if (_searchQuery.isEmpty ||
            crime['type'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            crime['description'].toLowerCase().contains(
              _searchQuery.toLowerCase(),
            )) {
          markers.add(
            Marker(
              point: crime['location'],
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => _showCrimeDetails(crime),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getCrimeColor(crime['severity']),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getCrimeIcon(crime['type']),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return markers;
  }

  String _getTileUrl() {
    switch (_selectedMapStyle) {
      case 'satellite':
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case 'dark':
        return 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png';
      case 'terrain':
        return 'https://stamen-tiles.a.ssl.fastly.net/terrain/{z}/{x}/{y}.png';
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  void _showMapStyleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Map Style',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStyleOption('Standard', 'standard', Icons.map),
                _buildStyleOption('Satellite', 'satellite', Icons.satellite),
                _buildStyleOption('Dark', 'dark', Icons.dark_mode),
                _buildStyleOption('Terrain', 'terrain', Icons.terrain),
              ],
            ),
          ),
    );
  }

  Widget _buildStyleOption(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedMapStyle == value ? Colors.blue : Colors.grey,
      ),
      title: Text(title),
      trailing:
          _selectedMapStyle == value
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
      onTap: () {
        setState(() => _selectedMapStyle = value);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const LinearGradient backgroundGradient = LinearGradient(
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
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Crime Map',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(
              _showCrimeLocations ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed:
                () =>
                    setState(() => _showCrimeLocations = !_showCrimeLocations),
            tooltip: 'Toggle Crime Locations',
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _showMapStyleSelector,
            tooltip: 'Map Style',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Enhanced Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search crime locations...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed:
                                    () => setState(() => _searchQuery = ''),
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Map Container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter:
                                  _currentLocation ??
                                  const LatLng(23.8103, 90.4125),
                              initialZoom: 13.0,
                              maxZoom: 18.0,
                              minZoom: 3.0,
                              onTap: (tapPosition, point) {
                                // Handle map tap
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: _getTileUrl(),
                                userAgentPackageName: 'com.example.zoneguard',
                                maxZoom: 19,
                              ),
                              if (_currentLocation != null)
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: _currentLocation!,
                                      radius: 100,
                                      color: Colors.blue.withOpacity(0.1),
                                      borderColor: Colors.blue.withOpacity(0.3),
                                      borderStrokeWidth: 2,
                                    ),
                                  ],
                                ),
                              MarkerLayer(markers: _buildMarkers()),
                            ],
                          ),

                          // Loading overlay
                          if (_isLoading)
                            Container(
                              color: Colors.black.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),

                          // Map controls
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Column(
                              children: [
                                _buildMapControl(Icons.add, () {
                                  _mapController.move(
                                    _mapController.camera.center,
                                    _mapController.camera.zoom + 1,
                                  );
                                }),
                                const SizedBox(height: 8),
                                _buildMapControl(Icons.remove, () {
                                  _mapController.move(
                                    _mapController.camera.center,
                                    _mapController.camera.zoom - 1,
                                  );
                                }),
                              ],
                            ),
                          ),

                          // Legend
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Crime Severity',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildLegendItem('High', Colors.red),
                                  _buildLegendItem('Medium', Colors.orange),
                                  _buildLegendItem('Low', Colors.yellow),
                                ],
                              ),
                            ),
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
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: _getCurrentLocation,
          backgroundColor: Colors.blue[600],
          child:
              _isLoading
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Icon(Icons.my_location, color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
