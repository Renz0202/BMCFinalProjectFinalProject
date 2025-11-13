import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 1. Get Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Use a getter so updates reflect immediately
  User? get _currentUser => _auth.currentUser;

  // 2. Form key and controllers for changing password
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Profile edit controllers
  final _displayNameController = TextEditingController();
  final _emailEditController = TextEditingController();
  final _photoUrlController = TextEditingController();

  // 3. State variables for loading
  bool _isLoading = false; // for password
  bool _updatingName = false;
  bool _updatingEmail = false;
  bool _updatingPhoto = false;

  @override
  void initState() {
    super.initState();
    final user = _currentUser;
    _displayNameController.text = user?.displayName ?? '';
    _emailEditController.text = user?.email ?? '';
    _photoUrlController.text = user?.photoURL ?? '';
  }

  // 4. Clean up controllers
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _emailEditController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _refreshUser() async {
    await _auth.currentUser?.reload();
    if (mounted) setState(() {});
  }

  Future<void> _updateDisplayName() async {
    final name = _displayNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Display name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _updatingName = true);
    try {
      await _currentUser?.updateDisplayName(name);
      await _refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Display name updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update name: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingName = false);
    }
  }

  Future<void> _updateEmail() async {
    final email = _emailEditController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _updatingEmail = true);
    try {
      // Newer Firebase Auth versions prefer verifyBeforeUpdateEmail.
      // This sends a verification email; after the user confirms, the email is updated.
      await _currentUser?.verifyBeforeUpdateEmail(email);
      await _refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification sent to $email. Please confirm to complete the update.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // requires-recent-login is common
      if (mounted) {
        final msg = switch (e.code) {
          'requires-recent-login' =>
            'Please re-login and try updating email again.',
          'invalid-email' => 'The email address is invalid.',
          'email-already-in-use' => 'That email is already in use.',
          _ => (e.message ?? 'Failed to update email'),
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingEmail = false);
    }
  }

  Future<void> _updatePhotoUrl() async {
    final url = _photoUrlController.text.trim();
    setState(() => _updatingPhoto = true);
    try {
      await _currentUser?.updatePhotoURL(url.isEmpty ? null : url);
      await _refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update photo: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingPhoto = false);
    }
  }

  // 1. This is the "Change Password" logic
  Future<void> _changePassword() async {
    // 2. Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 3. This is the Firebase command to update the password
      await _currentUser!.updatePassword(_newPasswordController.text);

      // 4. Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Clear the fields
      _formKey.currentState!.reset();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      // 5. Handle errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // For debug
      // ignore: avoid_print
      print("Error changing password: ${e.code}");
      // e.code 'requires-recent-login' is a common error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final photoUrl = user?.photoURL;
    final email = user?.email ?? 'Not logged in';
    final displayName = user?.displayName ?? '';
    final uid = user?.uid ?? '';
    final created = user?.metadata.creationTime;
    final lastSignIn = user?.metadata.lastSignInTime;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? Text(
                            (displayName.isNotEmpty
                                    ? displayName[0]
                                    : (email.isNotEmpty ? email[0] : '?'))
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName.isNotEmpty ? displayName : 'No display name',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(email, style: Theme.of(context).textTheme.bodyMedium),
                  if (uid.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'UID: $uid',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (created != null || lastSignIn != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Member since: ${created?.toLocal()} | Last sign-in: ${lastSignIn?.toLocal()}',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Edit Profile Section
            Text('Edit Profile', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            // Display Name
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _updatingName ? null : _updateDisplayName,
              child: _updatingName
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Update Name'),
            ),

            const SizedBox(height: 16),

            // Email
            TextField(
              controller: _emailEditController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _updatingEmail ? null : _updateEmail,
              child: _updatingEmail
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Update Email'),
            ),

            const SizedBox(height: 16),

            // Photo URL
            TextField(
              controller: _photoUrlController,
              decoration: const InputDecoration(
                labelText: 'Photo URL (optional)',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _updatingPhoto ? null : _updatePhotoUrl,
              child: _updatingPhoto
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Update Photo'),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Change Password Form (kept)
            Text(
              'Change Password',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Change Password'),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
