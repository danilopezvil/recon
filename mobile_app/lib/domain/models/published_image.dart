class PublishedImage {
  const PublishedImage({
    required this.id,
    required this.imageUrl,
    required this.sortOrder,
  });

  final String id;
  final String imageUrl;
  final int sortOrder;

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_url': imageUrl,
        'sort_order': sortOrder,
      };

  factory PublishedImage.fromJson(Map<String, dynamic> json) => PublishedImage(
        id: json['id'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      );
}
