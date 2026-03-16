import '../../domain/models/analyze_draft_result.dart';
import '../../domain/models/analyzed_item.dart';
import '../../domain/models/confirm_draft_payload.dart';
import '../../domain/models/published_image.dart';
import '../../domain/models/published_item.dart';

class SuggestionDto {
  const SuggestionDto(this.title, this.description, this.price, this.category, this.condition, this.pickupArea);

  final String title;
  final String description;
  final int price;
  final String category;
  final String condition;
  final String pickupArea;

  factory SuggestionDto.fromJson(Map<String, dynamic> json) => SuggestionDto(
        json['title'] as String? ?? '',
        json['description'] as String? ?? '',
        (json['price'] as num?)?.toInt() ?? 0,
        json['category'] as String? ?? '',
        json['condition'] as String? ?? '',
        json['pickup_area'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'condition': condition,
        'pickup_area': pickupArea,
      };

  AnalyzedItem toDomain() => AnalyzedItem(
        title: title,
        description: description,
        price: price,
        category: category,
        condition: condition,
        pickupArea: pickupArea,
      );

  static SuggestionDto fromDomain(AnalyzedItem item) => SuggestionDto(
        item.title,
        item.description,
        item.price,
        item.category,
        item.condition,
        item.pickupArea,
      );
}

class AnalyzeResponseDto {
  const AnalyzeResponseDto({required this.draftId, required this.imageUrl, required this.suggestion});

  final String draftId;
  final String imageUrl;
  final SuggestionDto suggestion;

  factory AnalyzeResponseDto.fromJson(Map<String, dynamic> json) => AnalyzeResponseDto(
        draftId: json['draft_id'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        suggestion: SuggestionDto.fromJson(Map<String, dynamic>.from(json['suggestion'] as Map? ?? {})),
      );

  AnalyzeDraftResult toDomain() => AnalyzeDraftResult(
        draftId: draftId,
        imageUrl: imageUrl,
        suggestion: suggestion.toDomain(),
      );
}

class ConfirmRequestDto {
  const ConfirmRequestDto({required this.draftId, required this.imageUrl, required this.suggestion});

  final String draftId;
  final String imageUrl;
  final SuggestionDto suggestion;

  Map<String, dynamic> toJson() => {
        'draft_id': draftId,
        'image_url': imageUrl,
        ...suggestion.toJson(),
      };

  static ConfirmRequestDto fromDomain(ConfirmDraftPayload payload) => ConfirmRequestDto(
        draftId: payload.draftId,
        imageUrl: payload.imageUrl,
        suggestion: SuggestionDto.fromDomain(payload.item),
      );
}

class PublishedImageDto {
  const PublishedImageDto({required this.id, required this.imageUrl, required this.sortOrder});

  final String id;
  final String imageUrl;
  final int sortOrder;

  factory PublishedImageDto.fromJson(Map<String, dynamic> json) => PublishedImageDto(
        id: json['id'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      );

  PublishedImage toDomain() => PublishedImage(id: id, imageUrl: imageUrl, sortOrder: sortOrder);
}

class PublishedItemDto {
  const PublishedItemDto({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.pickupArea,
    required this.status,
    required this.createdAt,
    required this.images,
  });

  final String id;
  final String title;
  final String description;
  final int price;
  final String category;
  final String condition;
  final String pickupArea;
  final String status;
  final DateTime createdAt;
  final List<PublishedImageDto> images;

  factory PublishedItemDto.fromJson(Map<String, dynamic> json) => PublishedItemDto(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        category: json['category'] as String? ?? '',
        condition: json['condition'] as String? ?? '',
        pickupArea: json['pickup_area'] as String? ?? '',
        status: json['status'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        images: (json['images'] as List<dynamic>? ?? <dynamic>[])
            .map((e) => PublishedImageDto.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  PublishedItem toDomain() => PublishedItem(
        id: id,
        title: title,
        description: description,
        price: price,
        category: category,
        condition: condition,
        pickupArea: pickupArea,
        status: status,
        createdAt: createdAt,
        images: images.map((e) => e.toDomain()).toList(),
      );
}
