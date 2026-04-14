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
  final List<String> tags;
  final String brand;
  final String category;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final String thumbnail;
  final List<String> images;
  final List<Review> reviews;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.category,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.availabilityStatus,
    required this.returnPolicy,
    required this.minimumOrderQuantity,
    required this.thumbnail,
    required this.images,
    required this.reviews,
  });

  Product copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    double? discountPercentage,
    double? rating,
    int? stock,
    List<String>? tags,
    String? brand,
    String? category,
    String? warrantyInformation,
    String? shippingInformation,
    String? availabilityStatus,
    String? returnPolicy,
    int? minimumOrderQuantity,
    String? thumbnail,
    List<String>? images,
    List<Review>? reviews,
  }) =>
      Product(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        price: price ?? this.price,
        discountPercentage: discountPercentage ?? this.discountPercentage,
        rating: rating ?? this.rating,
        stock: stock ?? this.stock,
        tags: tags ?? this.tags,
        brand: brand ?? this.brand,
        category: category ?? this.category,
        warrantyInformation: warrantyInformation ?? this.warrantyInformation,
        shippingInformation: shippingInformation ?? this.shippingInformation,
        availabilityStatus: availabilityStatus ?? this.availabilityStatus,
        returnPolicy: returnPolicy ?? this.returnPolicy,
        minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
        thumbnail: thumbnail ?? this.thumbnail,
        images: images ?? this.images,
        reviews: reviews ?? this.reviews,
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
        tags: json["tags"] != null
            ? List<String>.from(json["tags"].map((x) => x.toString()))
            : [],
        brand: json["brand"] ?? 'Unknown Brand',
        category: json["category"] ?? 'Uncategorized',
        warrantyInformation: json["warrantyInformation"] ?? 'N/A',
        shippingInformation: json["shippingInformation"] ?? 'N/A',
        availabilityStatus: json["availabilityStatus"] ?? 'Unknown',
        returnPolicy: json["returnPolicy"] ?? 'N/A',
        minimumOrderQuantity: json["minimumOrderQuantity"] ?? 1,
        thumbnail: json["thumbnail"] ?? '',
        images: json["images"] != null
            ? List<String>.from(json["images"].map((x) => x.toString()))
            : [],
        reviews: json["reviews"] != null
            ? List<Review>.from(json["reviews"].map((x) => Review.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "price": price,
        "discountPercentage": discountPercentage,
        "rating": rating,
        "stock": stock,
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "brand": brand,
        "category": category,
        "warrantyInformation": warrantyInformation,
        "shippingInformation": shippingInformation,
        "availabilityStatus": availabilityStatus,
        "returnPolicy": returnPolicy,
        "minimumOrderQuantity": minimumOrderQuantity,
        "thumbnail": thumbnail,
        "images": List<dynamic>.from(images.map((x) => x)),
        "reviews": List<dynamic>.from(reviews.map((x) => x.toJson())),
      };
}

class Review {
  final int rating;
  final String comment;
  final DateTime? date;
  final String reviewerName;
  final String reviewerEmail;

  Review({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        rating: json["rating"] ?? 0,
        comment: json["comment"] ?? '',
        date: json["date"] != null ? DateTime.tryParse(json["date"]) : null,
        reviewerName: json["reviewerName"] ?? 'Unknown',
        reviewerEmail: json["reviewerEmail"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "rating": rating,
        "comment": comment,
        "date": date?.toIso8601String(),
        "reviewerName": reviewerName,
        "reviewerEmail": reviewerEmail,
      };
}
