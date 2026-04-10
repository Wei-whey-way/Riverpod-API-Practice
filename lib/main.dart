import 'package:api_with_riverpod/src/home.dart';
import 'package:api_with_riverpod/src/models/product.dart';
import 'package:api_with_riverpod/src/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
      const ProviderScope(child: MyApp())); //Wrap entire app with ProviderScope
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Named routes make navigation calls cleaner and centrally managed
      initialRoute: '/',
      routes: {
        '/': (context) =>
            const HomeView(), //Entry point widget. Creates initial app (repo/home.dart)
      },

      // onGenerateRoute handles routes that need arguments (like '/product')
      onGenerateRoute: (settings) {
        if (settings.name == '/product') {
          // Cast the passed argument back to a Product object
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          );
        }
        return null; // Unknown route
      },
    );
  }
}
