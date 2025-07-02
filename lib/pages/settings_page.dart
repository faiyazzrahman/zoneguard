import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/bottom_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // User settings
  double _notificationRadius = 5.0;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _locationSharing = true;
  bool _anonymousPosting = false;

  int _currentIndex = 4;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _profilePictureUrl;
  String? _userId;

  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (!_supabaseService.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      _userId = _supabaseService.currentUser!.id;

      // Load user profile data
      final profile = await _supabaseService.getCurrentUserProfile();

      // Load user settings (keeping the original settings structure)
      final settingsResponse =
          await _supabaseService.client
              .from('user_settings')
              .select()
              .eq('user_id', _userId!)
              .maybeSingle();

      if (mounted) {
        setState(() {
          if (profile != null) {
            _usernameController.text = profile['username'] ?? '';
            _emailController.text = profile['email'] ?? '';
            _profilePictureUrl = profile['profile_picture'];

            // If you have a name field in your profile, use it
            // Otherwise, use username as display name
            _nameController.text = profile['name'] ?? profile['username'] ?? '';
          }

          if (settingsResponse != null) {
            _notificationRadius =
                (settingsResponse['notification_radius_km'] ?? 5.0).toDouble();
            _emailNotifications =
                settingsResponse['email_notifications'] ?? true;
            _pushNotifications = settingsResponse['push_notifications'] ?? true;
            _locationSharing = settingsResponse['location_sharing'] ?? true;
            _anonymousPosting = settingsResponse['anonymous_posting'] ?? false;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading user data: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_userId == null) return;

    setState(() => _isSaving = true);

    try {
      // Update user profile using SupabaseService
      await _supabaseService.updateUserProfile(
        username: _usernameController.text.trim(),
      );

      // Update user settings (keeping the original settings structure)
      await _supabaseService.client.from('user_settings').upsert({
        'user_id': _userId!,
        'notification_radius_km': _notificationRadius,
        'email_notifications': _emailNotifications,
        'push_notifications': _pushNotifications,
        'location_sharing': _locationSharing,
        'anonymous_posting': _anonymousPosting,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Update password if provided
      if (_passwordController.text.isNotEmpty) {
        await _supabaseService.client.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );
        _passwordController.clear();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving settings: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _supabaseService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
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
        Navigator.pushReplacementNamed(context, '/post');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/inbox');
        break;
      case 4:
        // Already on settings page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).primaryColor;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                _profilePictureUrl != null
                                    ? NetworkImage(_profilePictureUrl!)
                                    : const NetworkImage(
                                      'https://i.pravatar.cc/150?img=12',
                                    ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text
                              : _usernameController.text.isNotEmpty
                              ? _usernameController.text
                              : 'User',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        if (_usernameController.text.isNotEmpty)
                          Text(
                            '@${_usernameController.text}',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement image picker for profile picture
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Photo upload feature coming soon!',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Change Photo',
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Account Settings Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isDark ? Colors.grey[800] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Display Name',
                            _nameController,
                            isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Username',
                            _usernameController,
                            isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Email',
                            _emailController,
                            isDark,
                            keyboardType: TextInputType.emailAddress,
                            enabled: false,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'New Password',
                            _passwordController,
                            isDark,
                            isPassword: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notification Settings Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isDark ? Colors.grey[800] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notification Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSwitchTile(
                            'Email Notifications',
                            'Receive crime alerts via email',
                            _emailNotifications,
                            (value) =>
                                setState(() => _emailNotifications = value),
                            isDark,
                          ),
                          _buildSwitchTile(
                            'Push Notifications',
                            'Receive crime alerts as push notifications',
                            _pushNotifications,
                            (value) =>
                                setState(() => _pushNotifications = value),
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Notification Radius: ${_notificationRadius.toStringAsFixed(1)} km',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Slider(
                            value: _notificationRadius,
                            min: 1.0,
                            max: 20.0,
                            divisions: 19,
                            label:
                                '${_notificationRadius.toStringAsFixed(1)} km',
                            onChanged:
                                (value) =>
                                    setState(() => _notificationRadius = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Privacy Settings Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isDark ? Colors.grey[800] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSwitchTile(
                            'Location Sharing',
                            'Allow the app to access your location',
                            _locationSharing,
                            (value) => setState(() => _locationSharing = value),
                            isDark,
                          ),
                          _buildSwitchTile(
                            'Anonymous Posting by Default',
                            'Post anonymously by default',
                            _anonymousPosting,
                            (value) =>
                                setState(() => _anonymousPosting = value),
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child:
                          _isSaving
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'SAVE CHANGES',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Additional Options
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isDark ? Colors.grey[800] : Colors.white,
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.help,
                          title: 'Help & Support',
                          isDark: isDark,
                          onTap: () {
                            // TODO: Navigate to help page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Help & Support coming soon!'),
                              ),
                            );
                          },
                        ),
                        _buildDivider(isDark),
                        _buildListTile(
                          icon: Icons.info,
                          title: 'About',
                          isDark: isDark,
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Crime Reporting App',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2024 Crime Reporting App',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logout Button
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => _showLogoutDialog(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'LOG OUT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.white70 : Colors.grey[700],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? Colors.grey[700] : Colors.grey[200],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isDark, {
    bool isPassword = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey[700],
        ),
        filled: true,
        fillColor:
            enabled
                ? (isDark
                    ? Colors.grey[700]?.withOpacity(0.2)
                    : Colors.grey[100])
                : (isDark ? Colors.grey[800] : Colors.grey[200]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: TextStyle(
        color:
            enabled
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? Colors.white54 : Colors.grey[600]),
        fontSize: 15,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
