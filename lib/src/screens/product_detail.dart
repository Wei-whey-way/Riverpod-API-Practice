import 'package:api_with_riverpod/src/models/product.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  // The Product object is passed directly — no extra API call needed.
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Tracks which image is currently shown in the gallery PageView
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // Use all product images for the gallery; fall back to thumbnail if empty
    final images =
        product.images.isNotEmpty ? product.images : [product.thumbnail];

    final hasBrand = product.brand.isNotEmpty &&
        product.brand.toLowerCase() != 'unknown brand' &&
        product.brand.toLowerCase() != 'null';

    final hasCategory = product.category.isNotEmpty &&
        product.category.toLowerCase() != 'unknown category' &&
        product.category.toLowerCase() != 'null';

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        backgroundColor: Colors
            .grey[50], // Very light grey to match the typical M3 app bar tint
        surfaceTintColor: Colors.transparent, // Disable dynamic tinting
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Gallery ---
            SizedBox(
              height: 280,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                                child: Icon(Icons.broken_image, size: 60)),
                      );
                    },
                  ),

                  // Left arrow
                  if (images.length > 1 && _currentImageIndex > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black38,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left,
                                size: 32, color: Colors.white),
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  // Right arrow
                  if (images.length > 1 &&
                      _currentImageIndex < images.length - 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black38,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right,
                                size: 32, color: Colors.white),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  // Dot indicators below the gallery
                  if (images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 12 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: _currentImageIndex == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Title ---
                  Text(
                    product.title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),

                  // --- Brand & Category chips ---
                  if (hasBrand || hasCategory) ...[
                    Row(
                      children: [
                        if (hasBrand) ...[
                          Chip(
                            label: Text(product.brand),
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (hasCategory)
                          Chip(
                            label: Text(product.category),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // --- Price & Discount ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (product.discountPercentage > 0) ...[
                        // Original price — crossed out
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Discounted price
                        Text(
                          '\$${(product.price * (1 - product.discountPercentage / 100)).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Discount badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.discountPercentage.toStringAsFixed(1)}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ] else ...[
                        // No discount — show price normally
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // --- Rating & Stock row ---
                  Row(
                    children: [
                      // Star rating
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) {
                              final diff = product.rating - index;
                              final iconData = diff >= 0.95
                                  ? Icons.star
                                  : (diff >= 0.5
                                      ? Icons.star_half
                                      : Icons.star_border);
                              return Icon(
                                iconData,
                                color: Colors.amber,
                                size: 20,
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${product.rating.toStringAsFixed(1)}/5.0",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),

                      // Stock badge — green if available, orange if low
                      Row(
                        children: [
                          Icon(
                            product.stock > 10
                                ? Icons.check_circle
                                : Icons.warning_amber_rounded,
                            size: 18,
                            color: product.stock > 10
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.stock} in stock',
                            style: TextStyle(
                              fontSize: 14,
                              color: product.stock > 10
                                  ? Colors.green[700]
                                  : Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),

                      // Shipping information
                      Row(
                        children: [
                          if (product.shippingInformation.isNotEmpty) ...[
                            Text(
                              product.shippingInformation,
                              style: const TextStyle(fontSize: 15, height: 1.6),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(width: 20),

                      // Minimum order quantity
                      Row(
                        children: [
                          if (product.minimumOrderQuantity > 0) ...[
                            Text(
                              'Minimum Order Quantity: ${product.minimumOrderQuantity}',
                              style: const TextStyle(fontSize: 15, height: 1.6),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // --- Divider ---
                  const Divider(),
                  const SizedBox(height: 12),

                  // --- Description ---
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: 16),

                  // --- Tags ---
                  if (product.tags.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Tags:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: product.tags
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          // fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // --- Divider ---
                  const Divider(),
                  const SizedBox(height: 12),

                  // --- Reviews Section ---
                  if (product.reviews.isNotEmpty) ...[
                    Text(
                      'Reviews (${product.reviews.length})',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...product.reviews.map((review) => Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Reviewer info & rating date
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.indigo.shade50,
                                    child: Text(
                                      review.reviewerName.isNotEmpty
                                          ? review.reviewerName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.indigo,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.reviewerName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            // Render 5 stars conditionally
                                            ...List.generate(
                                              5,
                                              (index) {
                                                final diff =
                                                    review.rating - index;
                                                final iconData = diff >= 0.95
                                                    ? Icons.star
                                                    : (diff >= 0.5
                                                        ? Icons.star_half
                                                        : Icons.star_border);
                                                return Icon(
                                                  iconData,
                                                  color: Colors.amber,
                                                  size: 14,
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            if (review.date != null)
                                              Text(
                                                '${review.date!.month}/${review.date!.day}/${review.date!.year}',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600]),
                                              ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Comment
                              Text(
                                review.comment,
                                style:
                                    const TextStyle(fontSize: 14, height: 1.4),
                              ),
                            ],
                          ),
                        )),
                  ] else ...[
                    const Text(
                      'Reviews',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No reviews yet.',
                      style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey),
                    ),
                  ],

                  // --- Divider ---
                  const Divider(),
                  const SizedBox(height: 12),

                  // Warranty, Return Policy, and Minimum Order Quantity
                  if (product.warrantyInformation.isNotEmpty ||
                      product.returnPolicy.isNotEmpty ||
                      product.minimumOrderQuantity > 0) ...[
                    const Text(
                      'Additional Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (product.warrantyInformation.isNotEmpty) ...[
                      Text(
                        'Warranty: ${product.warrantyInformation}',
                        style: const TextStyle(fontSize: 15, height: 1.6),
                      ),
                    ],
                    if (product.returnPolicy.isNotEmpty) ...[
                      Text(
                        'Return Policy: ${product.returnPolicy}',
                        style: const TextStyle(fontSize: 15, height: 1.6),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
