// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
    final int id;
    final String title;
    final String description;
    final double price;
    final double discountPercentage;
    final double rating;
    final int stock;
    final String brand;
    final String category;
    final String thumbnail;
    final List<String> images;

    Product({
        required this.id,
        required this.title,
        required this.description,
        required this.price,
        required this.discountPercentage,
        required this.rating,
        required this.stock,
        required this.brand,
        required this.category,
        required this.thumbnail,
        required this.images,
    });

    Product copyWith({
        int? id,
        String? title,
        String? description,
        double? price,
        double? discountPercentage,
        double? rating,
        int? stock,
        String? brand,
        String? category,
        String? thumbnail,
        List<String>? images,
    }) => 
        Product(
            id: id ?? this.id,
            title: title ?? this.title,
            description: description ?? this.description,
            price: price ?? this.price,
            discountPercentage: discountPercentage ?? this.discountPercentage,
            rating: rating ?? this.rating,
            stock: stock ?? this.stock,
            brand: brand ?? this.brand,
            category: category ?? this.category,
            thumbnail: thumbnail ?? this.thumbnail,
            images: images ?? this.images,
        );

    // INTERACTION POINT: This factory is called by the ProductController after fetching raw API data.
    // It takes the untyped Map<String, dynamic> and safely extracts values, applying fallback
    // defaults (e.g., ?? 0.0) in case the API misses returning specific fields.
    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"] ?? 0,
        title: json["title"] ?? 'Unknown',
        description: json["description"] ?? 'No description',
        price: json["price"]?.toDouble() ?? 0.0,
        discountPercentage: json["discountPercentage"]?.toDouble() ?? 0.0,
        rating: json["rating"]?.toDouble() ?? 0.0,
        stock: json["stock"] ?? 0,
        brand: json["brand"] ?? 'Unknown Brand',
        category: json["category"] ?? 'Uncategorized',
        thumbnail: json["thumbnail"] ?? '',
        images: json["images"] != null ? List<String>.from(json["images"].map((x) => x.toString())) : [],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "price": price,
        "discountPercentage": discountPercentage,
        "rating": rating,
        "stock": stock,
        "brand": brand,
        "category": category,
        "thumbnail": thumbnail,
        "images": List<dynamic>.from(images.map((x) => x)),
    };
}
