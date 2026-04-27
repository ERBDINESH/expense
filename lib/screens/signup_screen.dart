import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_navigation_screen.dart';

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
                  MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
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

  Future<void> _handleGoogleSignup() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await _authService.signInWithGoogle(isSignUp: true);
      if (userCredential != null && mounted) {
        _showAlertDialog(
          title: 'Success',
          message: 'Your account has been created successfully!',
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showAlertDialog(
          title: 'Signup Failed',
          message: 'Could not sign up with Google.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Account'),
      ),
      body: Stack(
        children: [
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
                        const SizedBox(height: 20),
                        // Custom Glowing Logo
                        Center(
                          child: Container(
                            height: 80,
                            width: 80,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset("assets/logo.png", fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 32, 
                              fontWeight: FontWeight.bold, 
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                            children: [
                              const TextSpan(text: 'Join '),
                              TextSpan(
                                text: 'Moniqo',
                                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start your wealth journey today',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant, 
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hint: 'Your Name',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'youremail@example.com',
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
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
                        
                        const SizedBox(height: 48),
                        
                        // Signup Button
                        ElevatedButton(
                          onPressed: _handleSignup,
                          child: const Text('Sign Up'),
                        ),
                        
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Google Button
                        OutlinedButton(
                          onPressed: _handleGoogleSignup,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).dividerColor),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            backgroundColor: Theme.of(context).cardColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                                height: 20,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Continue with Google',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        // Sign In Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? ", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label, 
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant, 
              fontSize: 13, 
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
          ),
          validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }
}
