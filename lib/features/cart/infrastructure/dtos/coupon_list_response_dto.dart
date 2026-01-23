// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/coupon_list_response.dart';
import 'coupon_dto.dart';

part 'coupon_list_response_dto.freezed.dart';
part 'coupon_list_response_dto.g.dart';

/// CouponListResponse DTO for JSON serialization
///
/// Maps API response structure to domain entity
/// Handles pagination metadata from Django Rest Framework
@freezed
class CouponListResponseDto with _$CouponListResponseDto {
  const factory CouponListResponseDto({
    required int count,
    required List<CouponDto> results,
    String? next,
    String? previous,
  }) = _CouponListResponseDto;

  const CouponListResponseDto._();

  factory CouponListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CouponListResponseDtoFromJson(json);

  /// Convert DTO to Entity
  CouponListResponse toEntity() {
    return CouponListResponse(
      count: count,
      next: next,
      previous: previous,
      results: results.map((dto) => dto.toEntity()).toList(),
    );
  }
}
