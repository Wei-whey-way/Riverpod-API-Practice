import 'package:api_with_riverpod/src/screens/home.dart';
import 'package:api_with_riverpod/src/screens/large_screen_layout.dart';
import 'package:flutter/material.dart';

// 600-pixel threshold is a common breakpoint that separates
// phone-sized screens from tablet/desktop-sized screens.
const largeScreenMinWidth = 600;

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder provides the parent's size constraints so we can
    // decide which layout to render based on available width.
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > largeScreenMinWidth;

        if (isLargeScreen) {
          return const LargeScreenLayout();
        } else {
          // Small screen: show the standard full-screen product list
          return const HomeView();
        }
      },
    );
  }
}
