import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  void _handleSignup() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;
  final confirmPassword = _confirmPasswordController.text;

  if (password != confirmPassword) {
    setState(() {
      _error = "Passwords do not match";
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('User creation failed');
    }

    // Save additional profile data
    await Supabase.instance.client
        .from('profiles')
        .insert({
          'id': user.id,
          'username': _usernameController.text.trim(),
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'nid': _nidController.text.trim(),
        });

    // Navigate to dashboard or show confirmation screen
    Navigator.pushReplacementNamed(context, '/dashboard');
  } on AuthException catch (e) {
    setState(() {
      _error = e.message;
    });
  } catch (e) {
    setState(() {
      _error = "An unexpected error occurred: $e";
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Icon(Icons.person_add, size: 72, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                _buildTextField(controller: _usernameController, hint: "Username", icon: Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField(controller: _firstNameController, hint: "First Name", icon: Icons.badge_outlined),
                const SizedBox(height: 16),
                _buildTextField(controller: _lastNameController, hint: "Last Name", icon: Icons.badge_outlined),
                const SizedBox(height: 16),
                _buildTextField(controller: _emailController, hint: "Email", icon: Icons.email_outlined),
                const SizedBox(height: 16),
                _buildTextField(controller: _nidController, hint: "NID Card Number", icon: Icons.credit_card),
                const SizedBox(height: 16),
                _buildTextField(controller: _passwordController, hint: "Password", icon: Icons.lock_outline, obscure: true),
                const SizedBox(height: 16),
                _buildTextField(controller: _confirmPasswordController, hint: "Confirm Password", icon: Icons.lock_person_outlined, obscure: true),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Color.fromARGB(255, 228, 222, 222)),
                    ),
                  ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3A7BD5),
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 6,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF3A7BD5))
                      : const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?", style: TextStyle(color: Colors.white70)),
                    TextButton(
                       onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
