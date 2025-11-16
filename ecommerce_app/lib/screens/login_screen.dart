import 'package:ecommerce_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // From Module 4

// This file combines the UI from Module 3 and the logic from Module 4
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 3. Create a GlobalKey for the Form (from Module 3)
  final _formKey = GlobalKey<FormState>();

  // 4. Create TextEditingControllers (from Module 3)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- Logic from Module 4 ---
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // --- End of Module 4 Logic ---

  // 5. Clean up controllers when the widget is removed (from Module 3)
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Login Function from Module 4 ---
  Future<void> _login() async {
    // 1. Check if the form is valid
    if (!_formKey.currentState!.validate()) {
      return; // If not valid, stop here
    }

    // 2. Set loading to true
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. This is the Firebase command to sign in
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // 4. If login is successful, the AuthWrapper's stream
      //    will auto-navigate to HomeScreen. We don't need to do it here.

    } on FirebaseAuthException catch (e) {
      // 5. This 'catch' block handles Firebase-specific errors
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      }
      
      // 6. Show the error message in a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // 7. Catch any other general errors
      print(e);
    }

    // 8. ALWAYS set loading to false at the end
    if (mounted) { // Check if the widget is still on screen
      setState(() {
        _isLoading = false;
      });
    }
  }
  // --- End of Module 4 Function ---

  @override
  Widget build(BuildContext context) {
    // UI from Module 3
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
                    return null; // 'null' means the input is valid
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
                  // 1. Call our new _login function
                  onPressed: _isLoading ? null : _login,  
                  
                  // 2. Show a spinner OR text based on _isLoading
                  child: _isLoading 
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ) 
                      : const Text('Login'),
                ),
                // --- End of Module 4 Update ---

                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}