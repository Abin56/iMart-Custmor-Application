// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/checkout_lines_response.dart';
import 'checkout_line_dto.dart';

part 'checkout_lines_response_dto.freezed.dart';
part 'checkout_lines_response_dto.g.dart';

@freezed
class CheckoutLinesResponseDto with _$CheckoutLinesResponseDto {
  const factory CheckoutLinesResponseDto({
    required int count,
    required List<CheckoutLineDto> results,
    String? next,
    String? previous,
  }) = _CheckoutLinesResponseDto;

  const CheckoutLinesResponseDto._();

  factory CheckoutLinesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CheckoutLinesResponseDtoFromJson(json);

  /// Convert DTO to Entity
  CheckoutLinesResponse toEntity() {
    return CheckoutLinesResponse(
      count: count,
      results: results.map((line) => line.toEntity()).toList(),
      next: next,
      previous: previous,
    );
  }
}
