import 'package:flutter/material.dart';
import 'home_screen.dart';

class ThankYouScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ThankYouScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Container(
                width: screenWidth * 0.8, // 80% of screen width
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF704214),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/thank_you.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Thank you for your purchase!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF704214),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your delicious coffee will be ready soon.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF704214),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF704214),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(userData: userData),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Back To Menu',
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
    );
  }
}
