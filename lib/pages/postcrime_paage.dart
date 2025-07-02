import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../widgets/bottom_nav.dart';
import '../services/supabase_service.dart';
import '../models/crime_category.dart';

class PostCrimePage extends StatefulWidget {
  const PostCrimePage({super.key});

  @override
  State<PostCrimePage> createState() => _PostCrimePageState();
}

class _PostCrimePageState extends State<PostCrimePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  LocationData? _location;
  bool _isPosting = false;
  bool _isLoadingLocation = false;
  bool _isAnonymous = false;
  int _currentIndex = 2;
  CrimeCategory? _selectedCrimeType;
  List<CrimeCategory> _crimeCategories = [];
  DateTime? _incidentTime;
  String? _locationText;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final ImageSource? source = await _showImageSourceDialog();

      if (source == null) return;

      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (picked != null && mounted) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to pick image: $e', Colors.red);
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Image Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          if (mounted) {
            _showSnackBar('Location service is required', Colors.orange);
          }
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          if (mounted) {
            _showSnackBar('Location permission is required', Colors.orange);
          }
          return;
        }
      }

      LocationData locData = await location.getLocation();
      if (mounted) {
        setState(() => _location = locData);
        _reverseGeocode(locData.latitude!, locData.longitude!);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to get location: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _reverseGeocode(double latitude, double longitude) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        setState(() {
          _locationText = [
                place.street,
                place.subLocality,
                place.locality,
                place.administrativeArea,
                place.country,
              ]
              .where((element) => element != null && element.isNotEmpty)
              .join(', ');
        });
      }
    } catch (e) {
      // Silently fail geocoding, location coordinates are still available
      print('Geocoding failed: $e');
    }
  }

  Future<void> _selectIncidentTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _incidentTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: 'Select incident date',
    );

    if (picked != null && context.mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime:
            _incidentTime != null
                ? TimeOfDay.fromDateTime(_incidentTime!)
                : TimeOfDay.now(),
        helpText: 'Select incident time',
      );

      if (time != null && mounted) {
        setState(() {
          _incidentTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedImage = null;
      _selectedCrimeType = null;
      _incidentTime = null;
      _isAnonymous = false;
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Crime'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Crime type selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crime Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<CrimeCategory>(
                        value: _selectedCrimeType,
                        decoration: const InputDecoration(
                          labelText: 'Crime Type *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        // Fix: Add isExpanded to prevent overflow
                        isExpanded: true,
                        items:
                            _crimeCategories.map((category) {
                              return DropdownMenuItem<CrimeCategory>(
                                value: category,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _parseColor(category.color),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(category.name)),
                                    _severityIcon(category.severity),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCrimeType = value);
                          // Debug print to verify selection
                          print('Selected crime type: ${value?.name}');
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Please select a crime type'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Title field (optional)
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                          hintText: 'Brief title for the incident',
                        ),
                        maxLength: 100,
                      ),
                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          hintText: 'Describe what happened in detail...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please provide a description';
                          }
                          if (value.trim().length < 10) {
                            return 'Description must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time and location card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time & Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Incident time
                      InkWell(
                        onTap: () => _selectIncidentTime(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Incident Time',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _incidentTime == null
                                          ? 'Tap to select (optional)'
                                          : _formatDateTime(_incidentTime!),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            _incidentTime == null
                                                ? Colors.grey
                                                : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _location != null
                                      ? Icons.location_on
                                      : Icons.location_off,
                                  color:
                                      _location != null
                                          ? Colors.green
                                          : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Spacer(),
                                if (_isLoadingLocation)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  TextButton.icon(
                                    onPressed: _getLocation,
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Refresh'),
                                  ),
                              ],
                            ),
                            if (_location != null) ...[
                              const SizedBox(height: 8),
                              if (_locationText != null) ...[
                                Text(
                                  _locationText!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                'Lat: ${_location!.latitude!.toStringAsFixed(6)}, '
                                'Lng: ${_location!.longitude!.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Location access required for reporting',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Evidence and settings card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Evidence & Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Image upload button
                      OutlinedButton.icon(
                        icon: Icon(
                          _selectedImage == null
                              ? Icons.add_photo_alternate
                              : Icons.check_circle,
                        ),
                        label: Text(
                          _selectedImage == null
                              ? 'Add Evidence Photo'
                              : 'Photo Added',
                        ),
                        onPressed: _pickImage,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          foregroundColor:
                              _selectedImage == null ? null : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Anonymous posting toggle
                      Row(
                        children: [
                          const Icon(Icons.visibility_off, color: Colors.grey),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Post anonymously',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Switch(
                            value: _isAnonymous,
                            onChanged:
                                (value) => setState(() => _isAnonymous = value),
                          ),
                        ],
                      ),
                      if (_isAnonymous)
                        Padding(
                          padding: const EdgeInsets.only(left: 32, top: 4),
                          child: Text(
                            'Your identity will be hidden from other users',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image preview
              if (_selectedImage != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Evidence Photo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed:
                                  () => setState(() => _selectedImage = null),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              const SizedBox(height: 16),
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

  Widget _severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return const Icon(Icons.warning, color: Colors.red, size: 20);
      case 'medium':
        return const Icon(Icons.warning, color: Colors.orange, size: 20);
      case 'low':
        return const Icon(Icons.info, color: Colors.yellow, size: 20);
      default:
        return const Icon(Icons.help, color: Colors.grey, size: 20);
    }
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
