import 'package:freezed_annotation/freezed_annotation.dart';

/// Converts string/int/double to double (handles API returning numbers as strings)
class StringToDoubleConverter implements JsonConverter<double, dynamic> {
  const StringToDoubleConverter();

  @override
  double fromJson(dynamic value) {
    if (value == null) {
      throw ArgumentError('Cannot convert null to double');
    }
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed == null) {
        throw ArgumentError('Cannot convert "$value" to double');
      }
      return parsed;
    }
    throw ArgumentError(
      'Cannot convert $value (${value.runtimeType}) to double',
    );
  }

  @override
  dynamic toJson(double value) => value;
}

/// Converts nullable string/int/double to nullable double
class NullableStringToDoubleConverter
    implements JsonConverter<double?, dynamic> {
  const NullableStringToDoubleConverter();

  @override
  double? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  dynamic toJson(double? value) => value;
}

/// Converts string/int to int (handles API returning numbers as strings)
class StringToIntConverter implements JsonConverter<int, dynamic> {
  const StringToIntConverter();

  @override
  int fromJson(dynamic value) {
    if (value == null) {
      throw ArgumentError('Cannot convert null to int');
    }
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed == null) {
        throw ArgumentError('Cannot convert "$value" to int');
      }
      return parsed;
    }
    throw ArgumentError('Cannot convert $value (${value.runtimeType}) to int');
  }

  @override
  dynamic toJson(int value) => value;
}

/// Converts nullable string/int to nullable int
class NullableStringToIntConverter implements JsonConverter<int?, dynamic> {
  const NullableStringToIntConverter();

  @override
  int? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  dynamic toJson(int? value) => value;
}
