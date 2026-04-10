import 'package:api_with_riverpod/src/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';

//This is the initial app
//Change from StatelessWidget to ConsumerWidget to use ref
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //WidgetRef is window to access providers
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
      ),
      body: FutureBuilder(
        // Note: FutureBuilder holds onto the same Future reference after it first resolves.
        // It won't automatically re-fetch data just because you navigate back to this screen.
        future: ref.watch(productControllerProvider).getProducts(),
        builder: (context, snapshot) {
          snapshot.data;

          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              // InkWell provides a Material ripple on tap
              return InkWell(
                // Navigate to the detail page via named route,
                // passing the full Product object as the route argument.
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/product',
                    arguments: products[index],
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Product Image ---
                      // Conditionally render the image if a valid URL exists
                      if (products[index].thumbnail.isNotEmpty) ...[
                        Image.network(
                          products[index].thumbnail,
                          height: 200,
                          width: double.infinity, // Take full width
                          fit: BoxFit
                              .contain, // Maintain aspect ratio without cropping
                        ),
                        const SizedBox(height: 12),
                      ],

                      // --- Product Title ---
                      // Displays the name of the product in a bold, prominent font
                      Text(
                        products[index].title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      // --- Brand & Category Subtitle ---
                      // Shows the brand and category grouped together
                      Text(
                        '${products[index].brand} • ${products[index].category}',
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),

                      // --- Product Description ---
                      Text(products[index].description),
                      const SizedBox(height: 12),

                      // --- Bottom Section: Pricing, Ratings, and Stock ---
                      // Uses a spaceBetween row to push price to the left and ratings/stock to the right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left Side: Price & Discount
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main Price
                              Text(
                                '\$${products[index].price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),

                              // Discount Tag (Optional)
                              if (products[index].discountPercentage > 0)
                                Text(
                                  '${products[index].discountPercentage}% OFF',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),

                          // Right Side: Rating & Stock Info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Star Rating
                              Text(
                                '⭐ ${products[index].rating}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),

                              // Stock Count
                              Text(
                                '${products[index].stock} in stock',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.blueGrey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
