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
        id: json['id'] as String,
        item: AnalyzedItem.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
        imagePath: json['image_path'] as String,
        imageBytes: (json['image_bytes'] as num).toInt(),
        published: json['published'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        message: json['message'] as String?,
      );
}
