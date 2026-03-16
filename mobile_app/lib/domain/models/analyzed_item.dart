class AnalyzedItem {
  const AnalyzedItem({
    required this.title,
    required this.price,
    required this.category,
    required this.condition,
    required this.pickupArea,
    required this.description,
    this.author,
    this.genre,
    this.language,
  });

  final String title;
  final int price;
  final String category;
  final String condition;
  final String pickupArea;
  final String description;
  final String? author;
  final String? genre;
  final String? language;

  AnalyzedItem copyWith({
    String? title,
    int? price,
    String? category,
    String? condition,
    String? pickupArea,
    String? description,
    String? author,
    String? genre,
    String? language,
  }) {
    return AnalyzedItem(
      title: title ?? this.title,
      price: price ?? this.price,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      pickupArea: pickupArea ?? this.pickupArea,
      description: description ?? this.description,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'price': price,
        'category': category,
        'condition': condition,
        'pickup_area': pickupArea,
        'description': description,
        if (author != null && author!.isNotEmpty) 'author': author,
        if (genre != null && genre!.isNotEmpty) 'genre': genre,
        if (language != null && language!.isNotEmpty) 'language': language,
      };

  factory AnalyzedItem.fromJson(Map<String, dynamic> json) => AnalyzedItem(
        title: json['title'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        category: json['category'] as String? ?? '',
        condition: json['condition'] as String? ?? 'good',
        pickupArea: json['pickup_area'] as String? ?? '',
        description: json['description'] as String? ?? '',
        author: json['author'] as String?,
        genre: json['genre'] as String?,
        language: json['language'] as String?,
      );
}
