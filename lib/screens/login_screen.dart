import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text('Login Failed', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final result = await _authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (result != null && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Invalid email or password.';
          if (e.toString().contains('user-not-found')) {
            errorMessage = 'No user found with this email.';
          } else if (e.toString().contains('wrong-password')) {
            errorMessage = 'Wrong password provided.';
          }
          _showErrorDialog(errorMessage);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await _authService.signInWithGoogle(isSignUp: false);
      if (userCredential != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String message = 'Could not sign in with Google.';
        if (e.toString().contains('user-not-found')) {
          message = 'No account found. Please register first using the Sign Up page.';
        }
        _showErrorDialog(message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            right: -100,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40),
                          // Custom Glowing Logo
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 56,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Welcome Text
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                              children: [
                                const TextSpan(text: 'Welcome '),
                                TextSpan(
                                  text: 'Back',
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sign in to track, manage & grow your money',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14),
                          ),
                          const SizedBox(height: 48),
                          
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
                                  hint: 'Enter your password',
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  obscureText: !_isPasswordVisible,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Custom Gradient Button
                          GestureDetector(
                            onTap: _handleLogin,
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
                                      'Sign In',
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
                          Row(
                            children: [
                              Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('OR', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Google Button
                          OutlinedButton(
                            onPressed: _handleGoogleSignIn,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              backgroundColor: Theme.of(context).cardColor,
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.g_mobiledata, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account? ", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 64),
                          // Footer Badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildFooterBadge(Icons.verified_user_rounded, 'Security'),
                              _buildFooterBadge(Icons.bolt_rounded, 'Insights'),
                              _buildFooterBadge(Icons.lock_rounded, 'Private'),
                            ],
                          ),
                          const SizedBox(height: 20),
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
                validator: (value) {
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

  Widget _buildFooterBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary.withOpacity(0.4), size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
