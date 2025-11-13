import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/screens/admin_panel_screen.dart';
import 'package:ecommerce_app/screens/product_detail_screen.dart';
import 'package:ecommerce_app/widgets/product_card.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/screens/order_history_screen.dart';
import 'package:ecommerce_app/widgets/notification_icon.dart'; // notification bell
import 'package:ecommerce_app/screens/profile_screen.dart'; // 1. ADD THIS
import 'package:ecommerce_app/screens/chat_screen.dart';
import 'package:ecommerce_app/screens/auth_wrapper.dart';
import 'package:ecommerce_app/widgets/shop_header.dart';
import 'package:ecommerce_app/screens/admin_chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userRole = 'user';
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String _searchQuery = '';
  String? _selectedCategory; // null or 'All' means no filter
  String? _profilePhotoUrl;
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .get();

      if (doc.exists && doc.data() != null && mounted) {
        final data = doc.data()!;
        final role = (data['role'] as String?) ?? 'user';
        final photoFromDb =
            (data['photoUrl'] as String?) ?? (data['photoURL'] as String?);
        final nameFromDb =
            (data['displayName'] as String?) ?? (data['name'] as String?);
        setState(() {
          _userRole = role;
          _profilePhotoUrl = photoFromDb ?? _currentUser.photoURL;
          _displayName =
              nameFromDb ?? _currentUser.displayName ?? _currentUser.email;
        });
        // Debug: print the role resolved for the current user
        debugPrint('Role for ${_currentUser.email}: $_userRole');
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }
  }

  // NOTE: Sign-out action has been moved to the Profile screen.

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    return Scaffold(
      appBar: ShopHeader(
        // Brand logo + name
        titleWidget: LayoutBuilder(
          builder: (context, titleConstraints) {
            return Row(
              children: [
                Image.asset(
                  'assets/image/AGP LIGHTS AND SOUNDS LOGO APPROVE_2.png',
                  height: 34,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                // Make brand text flexible so it truncates if actions crowd space.
                const Expanded(
                  child: Text(
                    'AGP Lights & Sounds',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: .3,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        onSearchChanged: (text) {
          setState(() => _searchQuery = text.trim());
        },
        actions: [
          // Cart icon with a badge showing item count
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Badge(
                label: Text(cart.itemCount.toString()),
                isLabelVisible: cart.itemCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Cart',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Order history icon
          const NotificationIcon(),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),
          if (_userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),
          if (_userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.support_agent),
              tooltip: 'Admin Chats',
              onPressed: () async {
                // Lazy import to avoid extra imports at top
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const _AdminChatsEntry(),
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    backgroundImage:
                        (_profilePhotoUrl != null &&
                            _profilePhotoUrl!.isNotEmpty)
                        ? NetworkImage(_profilePhotoUrl!)
                        : null,
                    child:
                        (_profilePhotoUrl == null || _profilePhotoUrl!.isEmpty)
                        ? Text(
                            _initialsFrom(
                              _displayName ?? _currentUser?.email ?? 'U',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  if (isWide) ...[
                    const SizedBox(width: 8),
                    Text(
                      _compactName(_displayName ?? _currentUser?.email ?? ''),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return; // safe async gap check
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthWrapper()),
                  (route) => false,
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No products found. Add some in the Admin Panel!'),
            );
          }

          final allDocs = snapshot.data!.docs;

          // Gather categories for filter chips
          final Set<String> categorySet = {
            for (final d in allDocs)
              (((d.data() as Map<String, dynamic>)['category'] as String?) ??
                  ''),
          }..removeWhere((c) => c.trim().isEmpty);
          final List<String> categories = [
            'All',
            ...categorySet.toList()..sort(),
          ];

          // Determine search query and selected category
          final query = _searchQuery.toLowerCase();
          final selected =
              (_selectedCategory == null || _selectedCategory == 'All')
              ? null
              : _selectedCategory;

          // Filter
          final products = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] as String?)?.toLowerCase() ?? '';
            final brand = (data['brand'] as String?)?.toLowerCase() ?? '';
            final category = (data['category'] as String?)?.toLowerCase() ?? '';

            final matchesQuery = query.isEmpty
                ? true
                : (name.contains(query) ||
                      brand.contains(query) ||
                      category.contains(query));

            final matchesCategory = selected == null
                ? true
                : category == selected.toLowerCase();

            return matchesQuery && matchesCategory;
          }).toList();

          // Responsive grid columns
          int crossAxisCount;
          if (width >= 1200) {
            crossAxisCount = 5;
          } else if (width >= 900) {
            crossAxisCount = 4;
          } else if (width >= 600) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 2;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters row: category chips and mobile search
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final c in categories)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                showCheckmark: false,
                                label: Text(c),
                                selected: (_selectedCategory ?? 'All') == c,
                                selectedColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                labelStyle: TextStyle(
                                  color: ((_selectedCategory ?? 'All') == c)
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                side: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withValues(alpha: 0.2),
                                ),
                                onSelected: (_) {
                                  setState(() => _selectedCategory = c);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!isWide) ...[
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          onChanged: (v) =>
                              setState(() => _searchQuery = v.trim()),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search products... ',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, innerConstraints) {
                    var effectiveCrossAxisCount = crossAxisCount;
                    if (products.length < effectiveCrossAxisCount) {
                      effectiveCrossAxisCount = products.isEmpty
                          ? 1
                          : products.length; // Avoid empty columns
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(10.0),
                      cacheExtent: 800,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: effectiveCrossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final productDoc = products[index];
                        final productData =
                            productDoc.data() as Map<String, dynamic>;

                        final name =
                            (productData['name'] as String?) ?? 'Unnamed';
                        final price =
                            (productData['price'] as num?)?.toDouble() ?? 0.0;
                        final imageUrl =
                            (productData['imageUrl'] as String?) ?? '';
                        final category =
                            (productData['category'] as String?) ?? '';
                        final brand = (productData['brand'] as String?) ?? '';

                        return ProductCard(
                          key: ValueKey(productDoc.id),
                          productName: name,
                          price: price,
                          imageUrl: imageUrl,
                          category: category,
                          brand: brand,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  productData: productData,
                                  productId: productDoc.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _userRole == 'user'
          ? StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                int unreadCount = 0;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data();
                  if (data != null && data is Map<String, dynamic>) {
                    unreadCount = (data['unreadByUserCount'] as int?) ?? 0;
                  }
                }

                return Badge(
                  label: Text('$unreadCount'),
                  isLabelVisible: unreadCount > 0,
                  child: FloatingActionButton.extended(
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Contact Admin'),
                    onPressed: () {
                      if (_currentUser != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(chatRoomId: _currentUser.uid),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            )
          : null,
    );
  }

  String _initialsFrom(String value) {
    final parts = value.trim().split(RegExp(r"\s+"));
    if (parts.length == 1) {
      final s = parts.first;
      if (s.isEmpty) return 'U';
      return s.characters.take(2).toString().toUpperCase();
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    final initials = (first + last).toUpperCase();
    return initials.isEmpty ? 'U' : initials;
  }

  String _compactName(String value) {
    final v = value.trim();
    if (v.isEmpty) return '';
    // For emails, show before '@'; for names, show first name only.
    if (v.contains('@')) {
      return v.split('@').first;
    }
    return v.split(RegExp(r"\s+")).first;
  }
}

// A small wrapper to avoid importing AdminChatListScreen in the header
class _AdminChatsEntry extends StatelessWidget {
  const _AdminChatsEntry();

  @override
  Widget build(BuildContext context) {
    // Directly reference the screen to keep HomeScreen imports tidy
    return const _AdminChatsScreenLoader();
  }
}

class _AdminChatsScreenLoader extends StatelessWidget {
  const _AdminChatsScreenLoader();

  @override
  Widget build(BuildContext context) {
    // Import here
    return AdminChatsRoute.build();
  }
}

// Separate route builder to isolate imports
class AdminChatsRoute {
  static Widget build() {
    // ignore: prefer_const_constructors
    return _AdminChatListScreenProxy();
  }
}

// Proxy widget to import the actual screen
class _AdminChatListScreenProxy extends StatelessWidget {
  const _AdminChatListScreenProxy();

  @override
  Widget build(BuildContext context) {
    // We import at file top normally, but to avoid circular concerns we're proxying
    return const _ActualAdminChatListScreen();
  }
}

// Finally, include the actual screen via a const constructor indirection
class _ActualAdminChatListScreen extends StatelessWidget {
  const _ActualAdminChatListScreen();
  @override
  Widget build(BuildContext context) {
    // Importing directly
    return AdminChatListScreen();
  }
}
