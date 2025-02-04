import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const DashboardScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final String? userName = userData['user']['name'];
    final String userEmail = userData['user']['email'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Coffee',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/coffee_beans_bg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.coffee,
                size: 100,
                color: Colors.brown,
              ),
              const SizedBox(height: 20),
              if (userName != null) ...[
                Text(
                  'Welcome $userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.brown,
                  ),
                ),
              ] else
                Text(
                  'Welcome $userEmail!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Your coffee dashboard is coming soon!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
