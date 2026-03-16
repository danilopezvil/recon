import 'published_image.dart';

class PublishedItem {
  const PublishedItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.pickupArea,
    required this.status,
    required this.createdAt,
    required this.images,
  });

  final String id;
  final String title;
  final String description;
  final int price;
  final String category;
  final String condition;
  final String pickupArea;
  final String status;
  final DateTime createdAt;
  final List<PublishedImage> images;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'condition': condition,
        'pickup_area': pickupArea,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'images': images.map((e) => e.toJson()).toList(),
      };

  factory PublishedItem.fromJson(Map<String, dynamic> json) => PublishedItem(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        category: json['category'] as String? ?? '',
        condition: json['condition'] as String? ?? '',
        pickupArea: json['pickup_area'] as String? ?? '',
        status: json['status'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        images: (json['images'] as List<dynamic>? ?? <dynamic>[])
            .map((e) => PublishedImage.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
