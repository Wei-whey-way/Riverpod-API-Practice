import 'package:flutter_riverpod/flutter_riverpod.dart';

// Filter for brand or category

// Holds the currently selected brand filter.
final selectedBrandProvider = StateProvider<String?>((ref) => null);

// Holds the currently selected category filter.
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
