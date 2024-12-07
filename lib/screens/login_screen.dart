import 'package:flutter/material.dart';
import '../screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username') ?? '';
    final storedPassword = prefs.getString('password') ?? '';

    if (username == storedUsername && password == storedPassword) {
      prefs.setString('loggedInUser', username); // Store logged-in user.
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Username'),
            TextField(controller: _usernameController),
            const SizedBox(height: 16),
            const Text('Password'),
            TextField(controller: _passwordController, obscureText: true),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
                child: const Text('Don\'t have an account? Signup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
