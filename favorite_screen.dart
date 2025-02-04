import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coffee.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class FavoriteScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const FavoriteScreen({super.key, required this.userData});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Coffee> _allCoffees = [];
  Set<String> _favoriteCoffees = {};
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadCoffees();
  }

  Future<void> _loadCoffees() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load all coffees
    String? coffeeData = prefs.getString('coffee_data');
    if (coffeeData != null) {
      final List<dynamic> decodedData = jsonDecode(coffeeData);
      _allCoffees = decodedData.map((item) => Coffee.fromJson(item)).toList();
    }

    // Load favorites for current user
    String? favoritesData = prefs.getString('favorites_${widget.userData['email']}');
    if (favoritesData != null) {
      _favoriteCoffees = Set<String>.from(jsonDecode(favoritesData));
    }

    setState(() {});
  }

  Future<void> _toggleFavorite(String coffeeName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteCoffees.contains(coffeeName)) {
        _favoriteCoffees.remove(coffeeName);
      } else {
        _favoriteCoffees.add(coffeeName);
      }
    });

    // Save updated favorites
    await prefs.setString(
      'favorites_${widget.userData['email']}',
      jsonEncode(_favoriteCoffees.toList()),
    );
  }

  void _onNavigationTap(int index) {
    if (index == 0) { // Home tab
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userData: widget.userData),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Favorite',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF704214),
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: const AssetImage('assets/images/profile_image.jpg'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF704214),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Find your best coffe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _allCoffees.length,
                  itemBuilder: (context, index) {
                    final coffee = _allCoffees[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF704214),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(
                            'assets/images/${coffee.image}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          coffee.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            _favoriteCoffees.contains(coffee.name)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          onPressed: () => _toggleFavorite(coffee.name),
                        ),
                      ),
                    );
                  },
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
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onNavigationTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }
}
