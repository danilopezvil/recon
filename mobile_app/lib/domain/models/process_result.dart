import 'analyzed_item.dart';

class ProcessResult {
  const ProcessResult({
    required this.id,
    required this.item,
    required this.imagePath,
    required this.imageBytes,
    required this.published,
    required this.createdAt,
    this.message,
  });

  final String id;
  final AnalyzedItem item;
  final String imagePath;
  final int imageBytes;
  final bool published;
  final DateTime createdAt;
  final String? message;

  ProcessResult copyWith({
    String? id,
    AnalyzedItem? item,
    String? imagePath,
    int? imageBytes,
    bool? published,
    DateTime? createdAt,
    String? message,
  }) {
    return ProcessResult(
      id: id ?? this.id,
      item: item ?? this.item,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      published: published ?? this.published,
      createdAt: createdAt ?? this.createdAt,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'item': item.toJson(),
        'image_path': imagePath,
        'image_bytes': imageBytes,
        'published': published,
        'created_at': createdAt.toIso8601String(),
        'message': message,
      };

  factory ProcessResult.fromJson(Map<String, dynamic> json) => ProcessResult(
        id: json['id'] as String? ?? '',
        item: AnalyzedItem.fromJson(Map<String, dynamic>.from(json['item'] as Map? ?? <String, dynamic>{})),
        imagePath: json['image_path'] as String? ?? '',
        imageBytes: (json['image_bytes'] as num?)?.toInt() ?? 0,
        published: json['published'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        message: json['message'] as String?,
      );
}
