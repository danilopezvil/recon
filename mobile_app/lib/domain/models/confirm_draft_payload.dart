import 'analyzed_item.dart';

class ConfirmDraftPayload {
  const ConfirmDraftPayload({
    required this.draftId,
    required this.imageUrl,
    required this.item,
  });

  final String draftId;
  final String imageUrl;
  final AnalyzedItem item;

  ConfirmDraftPayload copyWith({
    String? draftId,
    String? imageUrl,
    AnalyzedItem? item,
  }) {
    return ConfirmDraftPayload(
      draftId: draftId ?? this.draftId,
      imageUrl: imageUrl ?? this.imageUrl,
      item: item ?? this.item,
    );
  }

  Map<String, dynamic> toJson() => {
        'draft_id': draftId,
        'image_url': imageUrl,
        ...item.toJson(),
      };
}
