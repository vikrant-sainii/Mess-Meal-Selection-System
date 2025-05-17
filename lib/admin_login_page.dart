import 'package:flutter/material.dart';
import 'package:hostelmess1/after_admin_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  bool isLoggingIn = false;  
  String email = "", password = "";
  final mailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  bool visible = true;


userlogin() async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('allowed_students')
          .doc(user.email)
          .get();

      if (doc.exists) {
        // ✅ Email found in Firestore → allowed student
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else {
        // ❌ Email not authorized → block access
        await FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Access denied. This email is not authorized as a student.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } on FirebaseAuthException catch (e) {
    final msg = e.code == 'user-not-found'
        ? "No user found for that email"
        : e.code == 'wrong-password'
            ? "Wrong password provided by the user"
            : "An error occurred";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo or Icon
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: const Icon(
                  Icons.admin_panel_settings,
                  size: 64,
                  color: Colors.deepPurpleAccent,
                ),
              ),
    
              const SizedBox(height: 30),
    
              const Text(
                "Admin Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
    
              const SizedBox(height: 40),
    
              // Email Field
              TextField(
                controller: mailcontroller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white10,
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.email, color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
    
              const SizedBox(height: 20),
    
              // Password Field
              TextField(
                controller: passwordcontroller,
                obscureText: visible,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white10,
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                  suffixIcon: IconButton(
                    icon: Icon(
                      visible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() {
                        visible = !visible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Login Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 149, 0, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (isLoggingIn) return;
    
                        if (mailcontroller.text.isNotEmpty && passwordcontroller.text.isNotEmpty) {
                          setState(() {
                            isLoggingIn = true;
                          });
    
                          email = mailcontroller.text;
                          password = passwordcontroller.text;
                          await userlogin();
    
                          setState(() {
                            isLoggingIn = false;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'LOGIN',
                                style: TextStyle(color: Colors.white, fontSize: 17),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
    
              const SizedBox(height: 20),
    
              const Text(
                "Only authorized personnel",
                style: TextStyle(color: Colors.white38),
              )
            ],
          ),
        ),
      ),
    );
  }
}