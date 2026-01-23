// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/coupon.dart';

part 'coupon_dto.freezed.dart';
part 'coupon_dto.g.dart';

@freezed
class CouponDto with _$CouponDto {
  const factory CouponDto({
    required int id,
    required String name,
    required String description,
    @JsonKey(name: 'discount_percentage') required String discountPercentage,
    required int limit,
    required bool status,
    required int usage,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') required DateTime endDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CouponDto;

  const CouponDto._();

  factory CouponDto.fromJson(Map<String, dynamic> json) =>
      _$CouponDtoFromJson(json);

  /// Convert DTO to Entity
  Coupon toEntity() {
    return Coupon(
      id: id,
      name: name,
      description: description,
      discountPercentage: discountPercentage,
      limit: limit,
      status: status,
      usage: usage,
      startDate: startDate,
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
