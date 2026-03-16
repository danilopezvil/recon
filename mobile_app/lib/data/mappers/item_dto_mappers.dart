import '../../domain/models/analyze_draft_result.dart';
import '../../domain/models/confirm_draft_payload.dart';
import '../../domain/models/published_item.dart';
import '../dtos/item_dtos.dart';

AnalyzeDraftResult mapAnalyzeResponseToDomain(AnalyzeResponseDto dto) => dto.toDomain();
ConfirmRequestDto mapConfirmPayloadToDto(ConfirmDraftPayload payload) => ConfirmRequestDto.fromDomain(payload);
PublishedItem mapPublishedItemToDomain(PublishedItemDto dto) => dto.toDomain();
