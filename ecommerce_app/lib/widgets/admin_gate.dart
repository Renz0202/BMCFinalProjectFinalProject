import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// AdminGate
/// Wrap any widget and allow rendering only if current user has role 'admin'.
/// It reads users/{uid}.role and shows a 403-like page when unauthorized.
class AdminGate extends StatelessWidget {
  final Widget child;
  final Widget? loading;
  final Widget? forbidden;

  const AdminGate({
    super.key,
    required this.child,
    this.loading,
    this.forbidden,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return forbidden ??
          _ForbiddenScaffold(onBack: () => Navigator.of(context).maybePop());
    }

    final userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDocStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ??
              const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return forbidden ??
              _ForbiddenScaffold(
                onBack: () => Navigator.of(context).maybePop(),
              );
        }
        final data = snapshot.data!.data();
        final role = data?['role'] as String?;
        if (role == 'admin') {
          return child;
        }
        return forbidden ??
            _ForbiddenScaffold(onBack: () => Navigator.of(context).maybePop());
      },
    );
  }
}

class _ForbiddenScaffold extends StatelessWidget {
  final VoidCallback onBack;
  const _ForbiddenScaffold({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access denied')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 12),
            const Text(
              'This area is restricted to administrators only.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
