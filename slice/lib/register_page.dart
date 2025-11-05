import 'package:flutter/material.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{
  final formKey = GlobalKey<FormState>();
  final bool obscureText = false;

  //controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      /*backgroundColor: const Color(0xFFF6FFF6),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/Slice.png', height: 100),
                ),
                const SizedBox(height: 12),
                const Text("Slice",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text("Create An Account",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Text("Enter your information to sign up for this app"),
                const SizedBox(height: 50),

                  //username
                TextField(
                  controller: _usernameController,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: "username",
                    border: OutlineInputBorder(),
                  ),
                ),

                //email
                const SizedBox(height: 20),
                TextField(
                  obscureText: false,
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),

                //password
                const SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  controller: _pwController,
                  decoration: InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),

                //confirm password
                const SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  controller: _confirmPwController,
                  decoration: InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),

                //buttons
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF90EE90),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: (){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  child: const Text("Sign Up"),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),*/
    );
  }
}