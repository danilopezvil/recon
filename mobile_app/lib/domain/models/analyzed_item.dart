class AnalyzedItem {
  const AnalyzedItem({
    required this.title,
    required this.price,
    required this.category,
    required this.condition,
    required this.pickupArea,
    required this.description,
  });

  final String title;
  final int price;
  final String category;
  final String condition;
  final String pickupArea;
  final String description;

  AnalyzedItem copyWith({
    String? title,
    int? price,
    String? category,
    String? condition,
    String? pickupArea,
    String? description,
  }) {
    return AnalyzedItem(
      title: title ?? this.title,
      price: price ?? this.price,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      pickupArea: pickupArea ?? this.pickupArea,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'condition': condition,
        'pickup_area': pickupArea,
      };

  factory AnalyzedItem.fromJson(Map<String, dynamic> json) => AnalyzedItem(
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        category: json['category'] as String? ?? '',
        condition: json['condition'] as String? ?? '',
        pickupArea: json['pickup_area'] as String? ?? '',
      );
}
