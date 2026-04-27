import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showMessage(String title, String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (!isError) Navigator.pop(context); // Go back to login
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        _showMessage(
          'Check your Mail',
          'We have sent a password reset link to $email. Please follow the instructions in the email to reset your password.',
        );
      }
    } catch (e) {
      if (mounted) {
        String error = 'Failed to send reset email.';
        if (e.toString().contains('user-not-found')) {
          error = 'No account found with this email.';
        }
        _showMessage('Error', error, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Reset your password',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Enter your email address below and we\'ll send you a link to reset your password.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'youremail@example.com',
              icon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _handleResetPassword,
                    child: const Text('Send Reset Link'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
          ),
        ),
      ],
    );
  }
}
