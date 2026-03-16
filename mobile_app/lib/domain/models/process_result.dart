class ProcessResult {
  static const int schemaVersion = 1;

  const ProcessResult({
    required this.id,
    required this.flowType,
    this.draftId,
    this.publishedItemId,
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.condition,
    required this.price,
    required this.pickupArea,
    required this.publishedAt,
    required this.success,
    this.message,
  });

  final String id;
  final String flowType;
  final String? draftId;
  final String? publishedItemId;
  final String imageUrl;
  final String title;
  final String category;
  final String condition;
  final int price;
  final String pickupArea;
  final DateTime publishedAt;
  final bool success;
  final String? message;

  ProcessResult copyWith({
    String? id,
    String? flowType,
    String? draftId,
    String? publishedItemId,
    String? imageUrl,
    String? title,
    String? category,
    String? condition,
    int? price,
    String? pickupArea,
    DateTime? publishedAt,
    bool? success,
    String? message,
  }) {
    return ProcessResult(
      id: id ?? this.id,
      flowType: flowType ?? this.flowType,
      draftId: draftId ?? this.draftId,
      publishedItemId: publishedItemId ?? this.publishedItemId,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      price: price ?? this.price,
      pickupArea: pickupArea ?? this.pickupArea,
      publishedAt: publishedAt ?? this.publishedAt,
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'flow_type': flowType,
        'draft_id': draftId,
        'published_item_id': publishedItemId,
        'image_url': imageUrl,
        'title': title,
        'category': category,
        'condition': condition,
        'price': price,
        'pickup_area': pickupArea,
        'published_at': publishedAt.toIso8601String(),
        'success': success,
        'message': message,
        'schema_version': schemaVersion,
      };

  factory ProcessResult.fromJson(Map<String, dynamic> json) {
    return ProcessResult(
        id: json['id'] as String,
        flowType: json['flow_type'] as String? ?? 'ai_assisted',
        draftId: json['draft_id'] as String?,
        publishedItemId: json['published_item_id'] as String?,
        imageUrl: json['image_url'] as String? ?? '',
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? '',
        condition: json['condition'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        pickupArea: json['pickup_area'] as String? ?? '',
        publishedAt: DateTime.parse(json['published_at'] as String),
        success: json['success'] as bool? ?? false,
        message: json['message'] as String?,
      );
  }
}
