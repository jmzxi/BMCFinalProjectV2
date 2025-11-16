import 'package:ecommerce_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // From Module 4
import 'package:cloud_firestore/cloud_firestore.dart'; // From Module 5

// This file combines UI (Mod 3), Auth logic (Mod 4), and Firestore logic (Mod 5)
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- From Module 4 ---
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // --- From Module 5 ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Sign Up Function (Combined from Module 4 & 5) ---
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. This is the Firebase command to CREATE a user (from Mod 4)
      final UserCredential userCredential = 
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. --- THIS IS THE NEW PART FROM MODULE 5 ---
      // After creating the user, save their info to Firestore
      if (userCredential.user != null) {
        // 3. Create a document in a 'users' collection
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text.trim(),
          'role': 'user', // 4. Set the default role to 'user'
          'createdAt': FieldValue.serverTimestamp(), // For our records
        });
      }
      // 5. AuthWrapper will auto-navigate to HomeScreen.

    } on FirebaseAuthException catch (e) {
      // 6. Handle specific sign-up errors (from Mod 4)
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // --- End of Sign Up Function ---

  @override
  Widget build(BuildContext context) {
    // UI from Module 3
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // --- Button updated in Module 4 ---
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  // 1. Call our new _signUp function
                  onPressed: _isLoading ? null : _signUp, 
                  
                  // 2. Show a spinner OR text
                  child: _isLoading 
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ) 
                      : const Text('Sign Up'),
                ),
                // --- End of Module 4 Update ---

                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}