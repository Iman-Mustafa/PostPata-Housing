import 'package:flutter/material.dart';
import 'package:frontend/presentation/views/home/home_screen.dart';

class LandlordHome extends StatelessWidget {
  const LandlordHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-property');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
      ),
    );
  }
}