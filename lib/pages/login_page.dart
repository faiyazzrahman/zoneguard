import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart'; // Adjust the import path as needed

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _error;
  bool _showForgotPassword = false;

  void _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    // Validation
    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _error = "Please fill in all fields";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _supabaseService.loginUser(
        emailOrUsername: identifier,
        password: password,
      );

      if (response.user != null) {
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome back!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        setState(() {
          _error = 'Login failed. Please check your credentials.';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
        // Show forgot password option for certain errors
        _showForgotPassword =
            e.message?.toLowerCase().contains('password') == true ||
            e.message?.toLowerCase().contains('invalid') == true;
      });
    } catch (e) {
      setState(() {
        String errorMessage = e.toString();

        // Handle specific error cases
        if (errorMessage.contains('Username not found')) {
          _error =
              "Username not found. Please check your username or use your email address.";
        } else if (errorMessage.contains('Invalid login credentials')) {
          _error = "Invalid email/username or password. Please try again.";
        } else if (errorMessage.contains('Email not confirmed')) {
          _error = "Please verify your email address before logging in.";
        } else if (errorMessage.contains('Too many requests')) {
          _error = "Too many login attempts. Please try again later.";
        } else {
          _error = 'Login failed. Please check your credentials and try again.';
        }

        _showForgotPassword = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() async {
    final identifier = _identifierController.text.trim();

    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // If identifier is not an email, show message
    if (!identifier.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address to reset password'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _supabaseService.resetPassword(identifier);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        setState(() {
          _showForgotPassword = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 72, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'SafeNav',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back! Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 48),

                _buildTextField(
                  controller: _identifierController,
                  hint: "Email or Username",
                  icon: Icons.person_outline,
                  obscure: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  hint: "Password",
                  icon: Icons.lock_outline,
                  obscure: true,
                ),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_showForgotPassword)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3A7BD5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFF3A7BD5),
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.white54)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white54)),
                  ],
                ),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: () {
                    // Placeholder for Google login integration
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google login coming soon!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                  label: const Text(
                    'Login with Google',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Help text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'You can login with either your email address or username',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
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
    required bool obscure,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
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
