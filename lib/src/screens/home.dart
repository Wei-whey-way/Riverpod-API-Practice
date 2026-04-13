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

  // Controller for the search text field.
  final TextEditingController _searchController = TextEditingController();

  // initState() runs exactly once when this widget is first inserted into
  // the widget tree. This is the right place to kick off a one-time fetch.
  @override
  void initState() {
    super.initState();
    // ref.read() (not ref.watch()) so that provider not called again when widget rebuilds
    _productsFuture = ref.read(productControllerProvider).getProducts();
  }

  // Cleans up memory leaks by discarding controller when user navigates away from page or closes widget
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch() because we want to rebuild the list when the user taps a chip or types in the search bar.
    final selectedBrand = ref.watch(selectedBrandProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Products (Small Screen Layout)",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
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

          // Apply all active filters for display.
          final filteredProducts = allProducts.where((p) {
            final brandMatch =
                selectedBrand == null || p.brand == selectedBrand;
            final categoryMatch =
                selectedCategory == null || p.category == selectedCategory;
            // Search matches against title or brand, case-insensitively.
            final query = searchQuery.trim().toLowerCase();
            final searchMatch = query.isEmpty ||
                p.title.toLowerCase().contains(query) ||
                p.brand.toLowerCase().contains(query);

            return brandMatch && categoryMatch && searchMatch;
          }).toList();

          return Column(
            children: [
              // --- Search Bar ---
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: TextField(
                  controller: _searchController,
                  // Update the provider on every keystroke so the list filters reactively.
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    // Show a clear button only when there is text in the field.
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                ),
              ),

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

              // Results Count
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredProducts.length} Results',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
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
                    // Material widget ensures InkWell splash doesn't bleed out of bounds
                    return Material(
                        color: Colors.transparent,
                        child: InkWell(
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),

                                // --- Bottom Row: Price (left) and Rating/Stock (right) ---
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Left Side: Price & Discount
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (filteredProducts[index]
                                                .discountPercentage >
                                            0) ...[
                                          // Original price — crossed out
                                          Text(
                                            '\$${filteredProducts[index].price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Discounted price
                                          Text(
                                            '\$${(filteredProducts[index].price * (1 - filteredProducts[index].discountPercentage / 100)).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Discount badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${filteredProducts[index].discountPercentage.toStringAsFixed(1)}% OFF',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ] else ...[
                                          // No discount — show price normally
                                          Text(
                                            '\$${filteredProducts[index].price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),

                                    // Right Side: Rating
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '⭐ ${filteredProducts[index].rating}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ));
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
