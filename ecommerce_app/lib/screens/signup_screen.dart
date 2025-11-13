import 'package:ecommerce_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  // Loading state and FirebaseAuth instance
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Sign up failed (${e.code}).';
    }
  }

  Future<void> _signUp() async {
    // ignore: avoid_print
    print('[SignUp] Submit tapped');
    if (!_formKey.currentState!.validate()) {
      // ignore: avoid_print
      print('[SignUp] Validation failed');
      return;
    }
    // Capture UI helpers before any awaits to avoid using BuildContext across async gaps
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      // ignore: avoid_print
      print('[SignUp] Creating user for ${_emailController.text.trim()}');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // ignore: avoid_print
      print('[SignUp] Success');

      // Save default role to Firestore for this user
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text.trim(),
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      // Show a picture dialog before proceeding to Home
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/image/AGP LIGHTS AND SOUNDS LOGO APPROVE_2.png',
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => const SizedBox(
                  height: 120,
                  child: Center(child: FlutterLogo(size: 72)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      );
      // AuthWrapper will auto-navigate to Home on success
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('[SignUp] FirebaseAuthException ${e.code}');
      messenger.showSnackBar(
        SnackBar(content: Text(_mapAuthError(e)), backgroundColor: Colors.red),
      );
    } catch (e) {
      // Optionally log other errors
      // ignore: avoid_print
      print(e);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AGP Sign Up')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/PA_BG.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  final isCompact = width < 360 || height < 650;
                  final double logoHeight = isCompact ? 52 : 64;
                  final double gapSmall = isCompact ? 12 : 16;
                  final double gapMed = isCompact ? 18 : 24;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      24 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                        elevation: 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 22 : 28,
                            vertical: isCompact ? 24 : 32,
                          ),
                          child: Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Image.asset(
                                  'assets/image/AGP LIGHTS AND SOUNDS LOGO APPROVE_2.png',
                                  height: logoHeight,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stack) =>
                                      const FlutterLogo(size: 64),
                                ),
                                SizedBox(height: gapSmall),
                                Text(
                                  'Create your AGP Lights & Sounds account',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: gapMed),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: Icon(Icons.person_outline),
                                    border: OutlineInputBorder(),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: gapSmall),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'you@example.com',
                                    prefixIcon: Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
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
                                SizedBox(height: gapSmall),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    border: const OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure1
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscure1 = !_obscure1,
                                      ),
                                    ),
                                  ),
                                  obscureText: _obscure1,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: gapSmall),
                                TextFormField(
                                  controller: _confirmController,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    border: const OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure2
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscure2 = !_obscure2,
                                      ),
                                    ),
                                  ),
                                  obscureText: _obscure2,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: gapMed),
                                SizedBox(
                                  height: isCompact ? 44 : 48,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _signUp,
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          )
                                        : const Text('Sign Up'),
                                  ),
                                ),
                                SizedBox(height: isCompact ? 8 : 12),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Already have an account? Login',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
