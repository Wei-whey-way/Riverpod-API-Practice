import 'package:flutter_riverpod/flutter_riverpod.dart';

// Filter for brand or category

// Holds the currently selected brand filter.
final selectedBrandProvider = StateProvider<String?>((ref) => null);

// Holds the currently selected category filter.
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Holds the current selected price range
final selectedPriceRange = StateProvider<String?>((ref) => null);

// Holds the current search query (empty string = no search filter active).
final searchQueryProvider = StateProvider<String>((ref) => '');

// Tracks whether the large screen layout is showing grid or list view.
final isGridViewProvider = StateProvider<bool>((ref) => false);
