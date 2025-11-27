import 'package:flutter/material.dart';
import 'package:slice/auth/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _auth = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  _signup() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      debugPrint("Missing fields");
      return;
    }

    if (password != confirm) {
      debugPrint("Passwords do not match");
      return;
    }

    final user = await _auth.signup(email, password);

    if (user != null) {
      debugPrint("Account created: ${user.email}");

      // Navigate to login OR home — your choice
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      debugPrint("Signup failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/slice_logo.jpeg', height: 100),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Slice',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Create an account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter your information to sign up for this app',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Username 
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Email 
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'email@domain.com',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Password 
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Confirm Password
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Sign Up button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9BE69D),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text.rich(
                  TextSpan(
                    text: 'By clicking continue, you agree to our ',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
