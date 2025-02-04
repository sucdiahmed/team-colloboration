import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import 'home_screen.dart';
import 'favorite_screen.dart';
import 'thank_you_screen.dart';
import 'profile_screen.dart';

class CartScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const CartScreen({super.key, required this.userData});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  int _selectedIndex = 3; // Cart tab

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    String? cartData = prefs.getString('cart_${widget.userData['email']}');
    if (cartData != null) {
      final List<dynamic> decodedData = jsonDecode(cartData);
      setState(() {
        _cartItems =
            decodedData.map((item) => CartItem.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cart_${widget.userData['email']}',
      jsonEncode(_cartItems.map((item) => item.toJson()).toList()),
    );
  }

  void _updateQuantity(int index, bool increase) {
    setState(() {
      if (increase) {
        _cartItems[index].quantity++;
      } else if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      }
    });
    _saveCartItems();
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    _saveCartItems();
  }

  void _onNavigationTap(int index) {
    if (index == 0) {
      // Home tab
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userData: widget.userData),
        ),
      );
    } else if (index == 1) {
      // Favorite tab
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FavoriteScreen(userData: widget.userData),
        ),
      );
    } else if (index == 2) {
      // Profile tab
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userData: widget.userData),
        ),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleCheckout() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear the cart
    await prefs.remove('cart_${widget.userData['email']}');
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ThankYouScreen(userData: widget.userData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cart',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF704214),
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        const AssetImage('assets/images/profile_image.jpg'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          // Coffee Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/${item.image}',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Coffee Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF704214),
                                  ),
                                ),
                                Text(
                                  '\$${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF704214),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildCircularButton(
                                      icon: Icons.remove,
                                      onTap: () =>
                                          _updateQuantity(index, false),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _buildCircularButton(
                                      icon: Icons.add,
                                      onTap: () => _updateQuantity(index, true),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Remove Button
                          _buildCircularButton(
                            icon: Icons.close,
                            onTap: () => _removeItem(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_cartItems.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThankYouScreen(userData: widget.userData),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF704214),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF704214),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavigationTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favirote'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFF000000),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
