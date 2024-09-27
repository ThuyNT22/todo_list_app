import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Image (Top-left corner)
        Align(
          alignment: Alignment.topLeft,
          child: Image.asset(
            'assets/top_image.png',  // Replace with your top image path
            width: 150,  // Adjusted width for smaller size
            height: 100, // Adjusted height for smaller size
            fit: BoxFit.contain,
          ),
        ),

        // Bottom Image (Bottom-right corner)
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0, bottom: 10.0), // Small padding to avoid screen edges
            child: Image.asset(
              'assets/bottom_image.png',  // Replace with your bottom image path
              width: 150,  // Adjusted width for smaller size
              height: 100, // Adjusted height for smaller size
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Child (The screen content will be placed here)
        child,
      ],
    );
  }
}
