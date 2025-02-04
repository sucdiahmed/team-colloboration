import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coffee.dart';
import '../models/cart_item.dart';
import 'favorite_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? userName;
  String _selectedCategory = 'Cappuccino';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<Coffee> _allCoffees = [];
  List<String> categories = ['Cappuccino', 'Espresso', 'Americano', 'Latte'];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _initializeCoffeeData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? widget.userData['email'].toString().split('@')[0];
    });
  }

  Future<void> _initializeCoffeeData() async {
    final prefs = await SharedPreferences.getInstance();
    String? coffeeData = prefs.getString('coffee_data');
    
    if (coffeeData == null) {
      // Initialize with default data
      _allCoffees = [
        Coffee(
          name: 'Cappuccino',
          description: 'with milk',
          rating: 4.5,
          price: 3.80,
          image: 'cappuccino.jpg',
          category: 'Cappuccino',
        ),
        Coffee(
          name: 'Cappuccino Lite',
          description: 'with low-fat milk',
          rating: 4.3,
          price: 4.00,
          image: 'cappuccino.jpg',
          category: 'Cappuccino',
        ),
        Coffee(
          name: 'Ice Cappuccino',
          description: 'with ice cream',
          rating: 4.7,
          price: 4.50,
          image: 'cappuccino.jpg',
          category: 'Cappuccino',
        ),
        Coffee(
          name: 'Americano',
          description: 'with hot water',
          rating: 4.2,
          price: 3.00,
          image: 'americano.jpg',
          category: 'Americano',
        ),
        Coffee(
          name: 'Latte',
          description: 'with steamed milk',
          rating: 4.6,
          price: 3.50,
          image: 'latte.jpg',
          category: 'Latte',
        ),
      ];

      // Save to SharedPreferences
      await prefs.setString('coffee_data', jsonEncode(_allCoffees.map((c) => c.toJson()).toList()));
    } else {
      // Load from SharedPreferences
      final List<dynamic> decodedData = jsonDecode(coffeeData);
      _allCoffees = decodedData.map((item) => Coffee.fromJson(item)).toList();
    }

    setState(() {});
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isNotEmpty) {
        // Find the first coffee that matches the search
        final matchingCoffee = _allCoffees.firstWhere(
          (coffee) => coffee.name.toLowerCase().contains(query) ||
                      coffee.description.toLowerCase().contains(query),
          orElse: () => _allCoffees[0],
        );
        // Switch to the category of the matching coffee
        _selectedCategory = matchingCoffee.category;
      }
    });
  }

  List<Coffee> get _filteredCoffees {
    if (_searchQuery.isEmpty) {
      return _allCoffees.where((coffee) => coffee.category == _selectedCategory).toList();
    }
    
    return _allCoffees
        .where((coffee) =>
            coffee.category == _selectedCategory &&
            (coffee.name.toLowerCase().contains(_searchQuery) ||
             coffee.description.toLowerCase().contains(_searchQuery)))
        .toList();
  }

  Future<void> _addToCart(Coffee coffee) async {
    final prefs = await SharedPreferences.getInstance();
    List<CartItem> cartItems = [];
    
    // Load existing cart items
    String? cartData = prefs.getString('cart_${widget.userData['email']}');
    if (cartData != null) {
      final List<dynamic> decodedData = jsonDecode(cartData);
      cartItems = decodedData.map((item) => CartItem.fromJson(item)).toList();
    }

    // Check if item already exists in cart
    int existingIndex = cartItems.indexWhere((item) => item.name == coffee.name);
    if (existingIndex != -1) {
      cartItems[existingIndex].quantity++;
    } else {
      // Add new item
      cartItems.add(CartItem(
        name: coffee.name,
        image: coffee.image,
        price: coffee.price,
        quantity: 1,
      ));
    }

    // Save updated cart
    await prefs.setString(
      'cart_${widget.userData['email']}',
      jsonEncode(cartItems.map((item) => item.toJson()).toList()),
    );

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${coffee.name} added to cart'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onNavigationTap(int index) {
    if (index == 1) { // Favorite tab
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FavoriteScreen(userData: widget.userData),
        ),
      );
    } else if (index == 2) { // Profile tab
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userData: widget.userData),
        ),
      );
    } else if (index == 3) { // Cart tab
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CartScreen(userData: widget.userData),
        ),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to',
                          style: TextStyle(
                            color: Color(0xFF324A59),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Daily Coffee',
                          style: TextStyle(
                            color: Color(0xFF704214),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: const AssetImage('assets/images/profile_image.jpg'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade100.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.brown),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Find your best coffee',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.brown),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Categories
                SizedBox(
                  height: 40,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) => 
                        _buildCategoryChip(
                          category,
                          isSelected: category == _selectedCategory,
                        ),
                      ).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Coffee items grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredCoffees.length,
                  itemBuilder: (context, index) {
                    final coffee = _filteredCoffees[index];
                    return _buildCoffeeItem(
                      coffee.name,
                      coffee.description,
                      coffee.rating,
                      coffee.price,
                      coffee.image,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Promo banner
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/coffee_promo.jpg',
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavigationTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        child: Chip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: isSelected ? Colors.brown : Colors.brown.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildCoffeeItem(String name, String description, double rating, double price, String image) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  'assets/images/$image',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            Text(
                              ' $rating',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          '\$$price',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () {
                _addToCart(Coffee(
                  name: name,
                  description: description,
                  rating: rating,
                  price: price,
                  image: image,
                  category: _selectedCategory,
                ));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF000000),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
