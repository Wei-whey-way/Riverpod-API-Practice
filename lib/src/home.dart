import 'package:api_with_riverpod/src/controller/filter_provider.dart';
import 'package:api_with_riverpod/src/controller/product_controller.dart';
import 'package:api_with_riverpod/src/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ConsumerStatefulWidget is a Riverpod-aware StatefulWidget.
// We use StatefulWidget (instead of plain ConsumerWidget) so we can store the Future in initState() and keep it stable across rebuilds.
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  // Homeview is the widget, _HomeViewState is the state.
  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

// _HomeViewState survives rebuilds unlike HomeView.
class _HomeViewState extends ConsumerState<HomeView> {
  // late means we promise to assign this before it's ever read.
  // We store the Future here so getProducts() is only ever called ONCE (in initState), not on every rebuild triggered by filter changes.
  late Future<List<Product>> _productsFuture;

  // initState() runs exactly once when this widget is first inserted into
  // the widget tree. This is the right place to kick off a one-time fetch.
  @override
  void initState() {
    super.initState();
    // ref.read() (not ref.watch()) so that provider not called again when widget rebuilds
    _productsFuture = ref.read(productControllerProvider).getProducts();
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch() because we want to rebuild the list when the user taps a chip.
    final selectedBrand = ref.watch(selectedBrandProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      // FutureBuilder listens to _productsFuture and calls builder() each time the Future's state changes
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          //Futurebuilder goes straight to key so no need to define classes. Snapshot and context will be defined in future
          if (snapshot.data == null) {
            return const Center(
              child:
                  CircularProgressIndicator(), // Show a loading spinner until data arrives.
            );
          }

          // allProducts holds the full, unfiltered list from the API. ! Assures Dart it is not null
          final allProducts = snapshot.data!;

          // Extract unique brands from the full product list.
          // .map() transforms each product into just its brand string.
          // .toSet() removes duplicates (a Set can't contain the same value twice).
          // .toList() converts back to a List so we can sort and index it.
          // ..sort() sorts alphabetically in-place (the cascade ".." returns the list itself).
          final brands = allProducts.map((p) => p.brand).toSet().toList()
            ..sort();

          final categories = allProducts.map((p) => p.category).toSet().toList()
            ..sort();

          //Apply filters for display
          final filteredProducts = allProducts.where((p) {
            final brandMatch =
                selectedBrand == null || p.brand == selectedBrand;
            final categoryMatch =
                selectedCategory == null || p.category == selectedCategory;

            return brandMatch && categoryMatch;
          }).toList();

          return Column(
            children: [
              // --- Brand Filter Row ---
              _buildFilterRow(
                label: 'Brand',
                options: brands,
                selected: selectedBrand,
                onSelected: (value) {
                  ref.read(selectedBrandProvider.notifier).state = value;
                },
              ),

              // --- Category Filter Row ---
              _buildFilterRow(
                label: 'Category',
                options: categories,
                selected: selectedCategory,
                onSelected: (value) {
                  ref.read(selectedCategoryProvider.notifier).state = value;
                },
              ),

              const Divider(height: 1),

              // --- Product List ---
              // Expanded makes the ListView fill all remaining vertical space
              // after the filter rows have taken their height.
              Expanded(
                child: ListView.builder(
                  // Use filteredProducts (not allProducts) so the list
                  // reflects the active brand/category selections.
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    // InkWell provides a Material ripple effect on tap
                    return InkWell(
                      // Navigate to the detail page, passing the tapped Product object
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/product',
                          arguments: filteredProducts[index],
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Product Image ---
                            // Only render the image widget if a URL is available
                            if (filteredProducts[index]
                                .thumbnail
                                .isNotEmpty) ...[
                              Image.network(
                                filteredProducts[index].thumbnail,
                                height: 200,
                                width: double.infinity, // Take full width
                                fit: BoxFit
                                    .contain, // Maintain aspect ratio without cropping
                              ),
                              const SizedBox(height: 12),
                            ],

                            // --- Product Title ---
                            Text(
                              filteredProducts[index].title,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),

                            // --- Bottom Row: Price (left) and Rating/Stock (right) ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left Side: Price & Discount
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '\$${filteredProducts[index].price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                    // Only show the discount tag if there is one
                                    if (filteredProducts[index]
                                            .discountPercentage >
                                        0)
                                      Text(
                                        '${filteredProducts[index].discountPercentage}% OFF',
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),

                                // Right Side: Rating & Stock
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '⭐ ${filteredProducts[index].rating}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      '${filteredProducts[index].stock} in stock',
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // A reusable helper that renders one horizontal row of FilterChips.
  //
  // Parameters:
  //   label    — the text shown before the chips (e.g. "Brand")
  //   options  — the list of chip labels to display (e.g. ["Apple", "Samsung"])
  //   selected — the currently active filter value (null = "All" chip is active)
  //   onSelected — callback fired when a chip is tapped; receives the new value
  //                (null when "All" is tapped, or the option string when a chip is tapped)
  Widget _buildFilterRow({
    required String label,
    required List<String> options,
    required String? selected,
    required void Function(String?) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // Static label on the left (e.g. "Brand: ")
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),

          // Expanded lets the scroll view take up all remaining horizontal space
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // "All" chip — selecting this clears the filter for this dimension.
                  // It's shown as selected (highlighted) when `selected` is null.
                  FilterChip(
                    label: const Text('All'),
                    // selected == null means no specific filter is set → "All" is active
                    selected: selected == null,
                    onSelected: (_) {
                      // Pass null to the callback to signal "clear this filter"
                      onSelected(null);
                    },
                  ),
                  const SizedBox(width: 6),

                  // One FilterChip per unique brand/category value
                  ...options.map((opt) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(opt),
                          // This chip is highlighted only if it matches the active filter
                          selected: selected == opt,
                          onSelected: (isSelected) {
                            // If this chip was just selected → set it as the filter.
                            // If it was already selected and tapped again → clear the filter (null).
                            onSelected(isSelected ? opt : null);
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
