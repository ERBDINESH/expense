import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showAlertDialog({required String title, required String message, bool isError = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.red : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (!isError) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              }
            },
            child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final result = await _authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          _usernameController.text.trim(),
        );

        if (result != null && mounted) {
          _showAlertDialog(
            title: 'Success',
            message: 'Your account has been created successfully!',
            isError: false,
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = e.toString();
          if (errorMessage.contains('email-already-in-use')) {
            errorMessage = 'This email is already registered.';
          } else if (errorMessage.contains('weak-password')) {
            errorMessage = 'The password provided is too weak.';
          } else {
            errorMessage = errorMessage.split(']').last.trim();
          }
          
          _showAlertDialog(
            title: 'Signup Failed',
            message: errorMessage,
            isError: true,
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.03),
              ),
            ),
          ),
          
          SafeArea(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Custom Glowing Logo
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Icon(
                              Icons.person_add_rounded,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                            children: [
                              const TextSpan(text: 'Create '),
                              TextSpan(
                                text: 'Account',
                                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join us to start tracking your expenses',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14),
                        ),
                        const SizedBox(height: 40),
                        
                        // Input Fields Container
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _usernameController,
                                label: 'Username',
                                hint: 'Your Name',
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 24),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                hint: 'youremail@example.com',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 24),
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'At least 6 characters',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                obscureText: !_isPasswordVisible,
                                onToggleVisibility: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                hint: 'Repeat password',
                                icon: Icons.lock_clock_outlined,
                                isPassword: true,
                                obscureText: !_isConfirmPasswordVisible,
                                onToggleVisibility: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Custom Gradient Button
                        GestureDetector(
                          onTap: _handleSignup,
                          child: Container(
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Theme.of(context).colorScheme.primary.withOpacity(0.8), Theme.of(context).colorScheme.primary],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  top: 10,
                                  bottom: 10,
                                  child: Container(
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        // Sign In Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? ", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              TextFormField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.3), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                validator: validator ?? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        if (isPassword)
          IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.2),
              size: 22,
            ),
            onPressed: onToggleVisibility,
          ),
      ],
    );
  }
}
