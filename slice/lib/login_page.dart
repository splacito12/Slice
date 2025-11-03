import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF6),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                const Text("Slice",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text("Login",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Text("Enter your Username or Email and Password"),
                const SizedBox(height: 20),
                const TextField(
                  decoration: InputDecoration(
                    hintText: "username or email@domain.com",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF90EE90),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: (){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatsScreen()),
                    );
                  },
                  child: const Text("Continue"),
                ),
                const SizedBox(height: 16),
                const Text("or"),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC0CB),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () {},
                  child: const Text("Sign Up"),
                ),
                const SizedBox(height: 16),
                /*ElevatedButton.icon(
                  icon: const Icon(Icons.g_mobiledate),
                  label: const Text("Continue with Google"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () {},
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}