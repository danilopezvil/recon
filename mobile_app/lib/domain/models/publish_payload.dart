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

  Map<String, dynamic> toJson() => {
        ...item.toJson(),
        'local_image_path': localImagePath,
        'created_at': createdAt.toIso8601String(),
      };
}
