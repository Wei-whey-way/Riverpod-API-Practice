import 'dart:convert';

import 'package:api_with_riverpod/src/models/product.dart';
import 'package:api_with_riverpod/src/repo/product_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Provider is a basic building block in Riverpod
final productControllerProvider = Provider((ref) {
  //Get access to product repo
  final productRepo = ref.watch(productRepoProvider);
  //Above code: Saying: before I build controller, I need a repo. GO find productRepoProvider and give ProductRepo object
  return ProductController(productRepo: productRepo);
});

class ProductController {
  // final productRepo = ProductRepo();
  final ProductRepo _productRepo; //Putting _ before name makes variable private

  ProductController({required ProductRepo productRepo})
      : _productRepo = productRepo;

  Future<List<Product>> getProducts() async {
    final response = await _productRepo.getProducts();
    final data = jsonDecode(response.body);
    List<Product> products = [];
    final productsJson = data['products'];

    for (dynamic productJson in productsJson) {
      // INTERACTION POINT: We pass raw Map data to the Product model's factory constructor.
      // The Product model acts as a mold, shaping the untyped JSON into a strongly typed
      // Product object with null-safety and proper data types.
      products.add(Product.fromJson(productJson));
    }
    return products;
  }
}
