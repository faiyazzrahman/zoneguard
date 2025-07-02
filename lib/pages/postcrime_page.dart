import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import '../widgets/bottom_nav.dart';

class PostCrimePage extends StatefulWidget {
  const PostCrimePage({super.key});

  @override
  State<PostCrimePage> createState() => _PostCrimePageState();
}

class _PostCrimePageState extends State<PostCrimePage> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  LocationData? _location;
  bool _isPosting = false;
  int _currentIndex = 2;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _getLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData locData = await location.getLocation();
    setState(() => _location = locData);
  }

  void _submitPost() async {
    if (_descriptionController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a description or photo before submitting.')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

      setState(() {
        _descriptionController.clear();
        _selectedImage = null;
        _location = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting report: $e')),
        );
      }
    } finally {
      setState(() => _isPosting = false);
    }
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        break; // Current page
      case 3:
        Navigator.pushReplacementNamed(context, '/inbox');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        title: Text(
          'Post Crimes',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      body: SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // User avatar + header
      Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                const NetworkImage('https://i.pravatar.cc/150?img=12'),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 16),
          Text(
            'Tell us what happened',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Unified input card
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        color: isDark ? Colors.grey[800] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Description field
              TextField(
                controller: _descriptionController,
                minLines: 5,
                maxLines: 10,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Describe what happened...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.grey[300]!,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image preview (if any)
              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

              if (_selectedImage != null) const SizedBox(height: 16),

              // Location info
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _location != null
                          ? 'Lat: ${_location!.latitude?.toStringAsFixed(4)}, Lng: ${_location!.longitude?.toStringAsFixed(4)}'
                          : 'Location not tagged',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[800],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _getLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Update'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PostActionButton(
                    icon: Icons.photo,
                    label: 'Add Photo',
                    color: primaryColor,
                    onTap: _pickImage,
                  ),
                  _PostActionButton(
                    icon: Icons.location_on,
                    label: 'Tag Location',
                    color: primaryColor,
                    onTap: _getLocation,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 30),

      // Submit button
      SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _isPosting ? null : _submitPost,
          icon: _isPosting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send),
          label: Text(
            _isPosting ? 'Submitting...' : 'Submit Report',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ],
  ),
),

      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.3 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
