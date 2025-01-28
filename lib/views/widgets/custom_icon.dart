//lib/views/widgets/custom_icon.dart
import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  const CustomIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Set dynamic sizes based on screen dimensions
    final iconWidth = screenWidth * 0.12; // 12% of screen width
    final iconHeight = screenHeight * 0.04; // 4% of screen height

    return SizedBox(
      width: iconWidth,
      height: iconHeight,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
              left: iconWidth * 0.2, // 20% of iconWidth for left margin
            ),
            width: iconWidth * 0.84, // 84% of iconWidth for width
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 250, 45, 108),
              borderRadius: BorderRadius.circular(iconHeight * 0.2), // Circular radius based on height
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              right: iconWidth * 0.2, // 20% of iconWidth for right margin
            ),
            width: iconWidth * 0.84, // 84% of iconWidth for width
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 32, 211, 234),
              borderRadius: BorderRadius.circular(iconHeight * 0.2), // Circular radius based on height
            ),
          ),
          Center(
            child: Container(
              height: double.infinity,
              width: iconWidth * 0.84, // 84% of iconWidth for width
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(iconHeight * 0.2), // Circular radius based on height
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
