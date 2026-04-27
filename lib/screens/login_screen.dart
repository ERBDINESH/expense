import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

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

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      // Unified Sign In / Sign Up with Google
      final userCredential = await _authService.signInWithGoogle(isSignUp: true);
      if (userCredential != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Could not sign in with Google. Please try again.');
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
          SafeArea(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Custom Glowing Logo
                        Center(
                          child: Container(
                            height: 120,
                            width: 120,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                  blurRadius: 40,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset("assets/logo.png", fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // App Name as Branding
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 56, 
                              fontWeight: FontWeight.bold, 
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -1,
                            ),
                            children: [
                              const TextSpan(text: 'Moni'),
                              TextSpan(
                                text: 'qo',
                                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Smart Wealth Tracking',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant, 
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 100),
                        
                        // Google Button
                        OutlinedButton(
                          onPressed: _handleGoogleSignIn,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).dividerColor),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            backgroundColor: Theme.of(context).cardColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                                height: 24,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Continue with Google',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface, 
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Secure & Private account access',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white24, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
