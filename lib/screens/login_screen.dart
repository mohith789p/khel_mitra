import 'package:flutter/material.dart';
import 'package:khel_mitra/input/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email = _emailController.text;
    final password = _passwordController.text;

    // TODO: Add your validation and login logic here
    bool loginSuccessful = true; // Replace with real login check

    if (loginSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful')),
      );
    } else {
      // Optionally show an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid login credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              const CustomTextField(
                hintText: 'Email address',
                icon: Icons.email,
                // controller: emailController,
              ),
              const SizedBox(height: 24),
              const CustomTextField(
                hintText: 'Password',
                icon: Icons.lock,
                obscureText: true,
                // controller: passwordController,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onLogin,
                  child: Text(
                    'Login',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
