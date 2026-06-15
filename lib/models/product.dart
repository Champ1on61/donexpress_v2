import 'dart:convert';

class Product {
  final String id;
  final String title;
  final double price;
  final String image;
  final String category;
  final double rating;        // 🔥 Рейтинг (0.0 - 5.0)
  final int reviewCount;      // 🔥 Количество отзывов

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    this.rating = 0,          // По умолчанию 0
    this.reviewCount = 0,     // По умолчанию 0
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'image': image,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
      category: json['category'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}