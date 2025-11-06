import 'dart:async'; // For StreamSubscription
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 1. A simple class to hold the data for an item in the cart
class CartItem {
  final String id; // The unique product ID
  final String name;
  final double price;
  int quantity; // Quantity can change, so it's not final

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1, // Default to 1 when added
  });

  // Convert CartItem to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'quantity': quantity};
  }

  // Create a CartItem from a Map (Firestore document)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}

// 1. The CartProvider class "mixes in" ChangeNotifier
class CartProvider with ChangeNotifier {
  // 2. Private list of items (not final because we'll replace it when fetching)
  List<CartItem> _items = [];

  // Track current user and auth subscription
  String? _userId;
  StreamSubscription<User?>? _authSubscription;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 3. Public getter to read the list
  List<CartItem> get items => _items;

  // 4. Total number of items (sum of quantities)
  int get itemCount {
    int total = 0;
    for (var item in _items) {
      total += item.quantity;
    }
    return total;
  }

  // 5. Total price
  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  // Constructor: listen to auth changes and fetch/clear cart accordingly
  CartProvider() {
    if (kDebugMode) {
      print('CartProvider initialized');
    }
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // User logged out
        if (kDebugMode) {
          print('User logged out, clearing cart.');
        }
        _userId = null;
        _items = [];
        notifyListeners();
      } else {
        // User logged in
        _userId = user.uid;
        if (kDebugMode) {
          print('User logged in: ${user.uid}. Fetching cart...');
        }
        _fetchCart();
      }
    });
  }

  // 6. Add item to cart
  void addItem(String id, String name, double price) {
    // 7. Check if item is already in the cart
    final index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
      // If present, increase quantity
      _items[index].quantity++;
    } else {
      // Else, add as new
      _items.add(CartItem(id: id, name: name, price: price));
    }

    // Save to Firestore (if logged in) and update UI
    _saveCart();
    notifyListeners();
  }

  // 11. Remove item from cart
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
    notifyListeners();
  }

  // Update quantity (increment or decrement). If quantity falls below 1, remove item.
  void updateQuantity(String id, int delta) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _items[index].quantity += delta;
    if (_items[index].quantity <= 0) {
      _items.removeAt(index);
    }
    _saveCart();
    notifyListeners();
  }

  // 1. Creates an order in the 'orders' collection
  Future<void> placeOrder() async {
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user is not logged in.');
    }

    try {
      final List<Map<String, dynamic>> cartData = _items
          .map((item) => item.toJson())
          .toList();
      final double total = totalPrice;
      final int count = itemCount;

      await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData,
        'totalPrice': total,
        'itemCount': count,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error placing order: $e');
      }
      rethrow;
    }
  }

  // 2. Clears the cart locally AND in Firestore
  Future<void> clearCart() async {
    _items = [];

    if (_userId != null) {
      try {
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        if (kDebugMode) {
          print('Firestore cart cleared.');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error clearing Firestore cart: $e');
        }
      }
    }

    notifyListeners();
  }

  // Fetch the cart from Firestore for the current user
  Future<void> _fetchCart() async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();

      if (doc.exists &&
          doc.data() != null &&
          doc.data()!['cartItems'] != null) {
        final List<dynamic> cartData =
            doc.data()!['cartItems'] as List<dynamic>;
        _items = cartData
            .map(
              (item) =>
                  CartItem.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
        if (kDebugMode) {
          print('Cart fetched successfully: ${_items.length} items');
        }
      } else {
        _items = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching cart: $e');
      }
      _items = [];
    }

    notifyListeners();
  }

  // Save the local cart to Firestore for the current user
  Future<void> _saveCart() async {
    if (_userId == null) return;

    try {
      final List<Map<String, dynamic>> cartData = _items
          .map((item) => item.toJson())
          .toList();
      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });
      if (kDebugMode) {
        print('Cart saved to Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving cart: $e');
      }
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
