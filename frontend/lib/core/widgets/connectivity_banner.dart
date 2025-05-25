import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.error,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: const Text(
        'No internet connection',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}