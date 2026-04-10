import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final productRepoProvider = Provider((ref) => ProductRepo());

class ProductRepo {
  Future<http.Response> getProducts() async {
    final url = Uri.parse('https://dummyjson.com/products');
    final response = await http.get(url);
    log(response.body);
    return response;
  }
}
