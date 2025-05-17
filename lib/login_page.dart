import 'package:flutter/material.dart';
import 'package:hostelmess1/admin_login_page.dart';
import 'homePage/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool isLoggingIn = false;
  String email = "", password = "";
  final mailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  bool visible = true;

// Removed duplicate import
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
          MaterialPageRoute(builder: (context) => const HomePage()),
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: IntrinsicHeight(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      collegeLogo(),
                      SizedBox(height: 30),
                      Text(
                        'Hostel Mess Login',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 30),
                      customTextField(
                        controller: mailcontroller,
                        hintText: "Email",
                        icon: Icons.email,
                        obscure: false,
                      ),
                      SizedBox(height: 15),
                      customTextField(
                        controller: passwordcontroller,
                        hintText: "Password",
                        icon: Icons.lock,
                        obscure: visible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            visible ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              visible = !visible;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 25),
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
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        "Powered by Mess Master DTII",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminLoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Admin Login",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget customTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.white),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget collegeLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
      ), // decoration: BoxDecoration(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/image1.jpeg', // use your actual image name
          height: 120,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
