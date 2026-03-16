import 'analyzed_item.dart';

class PublishPayload {
  const PublishPayload({
    required this.item,
    required this.localImagePath,
    required this.createdAt,
  });

  final AnalyzedItem item;
  final String localImagePath;
  final DateTime createdAt;

  PublishPayload copyWith({
    AnalyzedItem? item,
    String? localImagePath,
    DateTime? createdAt,
  }) {
    return PublishPayload(
      item: item ?? this.item,
      localImagePath: localImagePath ?? this.localImagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        ...item.toJson(),
        'local_image_path': localImagePath,
        'created_at': createdAt.toIso8601String(),
      };

  factory PublishPayload.fromJson(Map<String, dynamic> json) => PublishPayload(
        item: AnalyzedItem.fromJson(json),
        localImagePath: json['local_image_path'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
