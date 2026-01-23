// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CouponDtoImpl _$$CouponDtoImplFromJson(Map<String, dynamic> json) =>
    _$CouponDtoImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      discountPercentage: json['discount_percentage'] as String,
      limit: (json['limit'] as num).toInt(),
      status: json['status'] as bool,
      usage: (json['usage'] as num).toInt(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$CouponDtoImplToJson(_$CouponDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'discount_percentage': instance.discountPercentage,
      'limit': instance.limit,
      'status': instance.status,
      'usage': instance.usage,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
