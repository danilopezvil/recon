import 'analyzed_item.dart';

class AnalyzeDraftResult {
  const AnalyzeDraftResult({
    required this.draftId,
    required this.imageUrl,
    required this.suggestion,
  });

  final String draftId;
  final String imageUrl;
  final AnalyzedItem suggestion;

  AnalyzeDraftResult copyWith({
    String? draftId,
    String? imageUrl,
    AnalyzedItem? suggestion,
  }) {
    return AnalyzeDraftResult(
      draftId: draftId ?? this.draftId,
      imageUrl: imageUrl ?? this.imageUrl,
      suggestion: suggestion ?? this.suggestion,
    );
  }

  Map<String, dynamic> toJson() => {
        'draft_id': draftId,
        'image_url': imageUrl,
        'suggestion': suggestion.toJson(),
      };

  factory AnalyzeDraftResult.fromJson(Map<String, dynamic> json) {
    return AnalyzeDraftResult(
      draftId: json['draft_id'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      suggestion: AnalyzedItem.fromJson(Map<String, dynamic>.from(json['suggestion'] as Map? ?? {})),
    );
  }
}
