import 'package:api_with_riverpod/src/controller/filter_provider.dart';
import 'package:api_with_riverpod/src/controller/product_controller.dart';
import 'package:api_with_riverpod/src/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ConsumerStatefulWidget is a Riverpod-aware StatefulWidget.
// We use StatefulWidget (instead of plain ConsumerWidget) so we can store the Future in initState() and keep it stable across rebuilds.
class LargeScreenLayout extends ConsumerStatefulWidget {
  const LargeScreenLayout({super.key});

  // LargeScreenLayout is the widget, _LargeScreenLayoutState is the state.
  @override
  ConsumerState<LargeScreenLayout> createState() => _LargeScreenLayoutState();
}

// _LargeScreenLayoutState survives rebuilds unlike LargeScreenLayout.
class _LargeScreenLayoutState extends ConsumerState<LargeScreenLayout> {
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
    final isGridView = ref.watch(isGridViewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Products (Large Screen Layout)",
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

              // --- Results Count & View Toggle ---
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
                    IconButton(
                      icon: Icon(
                        isGridView ? Icons.view_list : Icons.grid_view,
                      ),
                      onPressed: () {
                        ref.read(isGridViewProvider.notifier).state =
                            !isGridView;
                      },
                      tooltip: isGridView ? 'Switch to list' : 'Switch to grid',
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // --- Product List or Grid ---
              // Expanded makes the view fill all remaining vertical space
              // after the filter rows and toggle row have taken their height.
              Expanded(
                child: isGridView
                    ? _buildGridView(filteredProducts)
                    : _buildListView(filteredProducts),
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

  // --- List View (original layout) ---
  Widget _buildListView(List<Product> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/product', arguments: product);
              },
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Product Image ---
                    if (product.thumbnail.isNotEmpty) ...[
                      Image.network(
                        product.thumbnail,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // --- Product Title ---
                    Text(
                      product.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    // --- Price (left) and Rating (right) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price & Discount
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (product.discountPercentage > 0) ...[
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${(product.price * (1 - product.discountPercentage / 100)).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${product.discountPercentage.toStringAsFixed(1)}% OFF',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ] else ...[
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Rating
                        Text(
                          '⭐ ${product.rating}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  // --- Grid View (2-column card layout) ---
  Widget _buildGridView(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 columns
        crossAxisSpacing: 12, // Horizontal gap between cards
        mainAxisSpacing: 12, // Vertical gap between cards
        childAspectRatio: 0.75, // Card height = width / 0.75 (taller than wide)
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Material(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias, // Ensures splash is clipped
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/product', arguments: product);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Thumbnail (fills top of card) ---
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: product.thumbnail.isNotEmpty
                        ? Image.network(
                            product.thumbnail,
                            width: double.infinity,
                            fit: BoxFit
                                .contain, //Contain ensures image are scaled proportionally to fit inside box rather than stretching
                          )
                        : const Center(
                            child:
                                Icon(Icons.image, size: 48, color: Colors.grey),
                          ),
                  ),
                ),

                // --- Card Info ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category label
                      Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Product title (truncated)
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Price row
                      if (product.discountPercentage > 0)
                        Row(
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '\$${(product.price * (1 - product.discountPercentage / 100)).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
