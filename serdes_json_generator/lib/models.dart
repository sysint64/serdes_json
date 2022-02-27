import 'package:equatable/equatable.dart';

class Field {
  final String name;
  final String jsonName;
  final FieldType type;

  const Field(this.name, this.jsonName, this.type);
}

class TypeAdapterField extends Field {
  final FieldType adapterType;
  final FieldType jsonContentType;

  TypeAdapterField(
    String name,
    String jsonName,
    FieldType type,
    this.adapterType,
    this.jsonContentType,
  ) : super(name, jsonName, type);
}

class UnionField extends Field {
  final String union;
  final Iterable<FieldUnionData> unionValues;

  UnionField(
    String name,
    String jsonName,
    FieldType type,
    this.union,
    this.unionValues,
  ) : super(name, jsonName, type);
}

class FieldUnionData {
  final String? value;
  final FieldType type;

  FieldUnionData(this.value, this.type);
}

// ignore: must_be_immutable
class FieldType extends Equatable {
  FieldType? parent;
  final String name;
  final List<FieldType> generics;
  final bool isPrimitive;
  final String displayName;
  final bool isOptional;

  FieldType({
    required this.name,
    required this.displayName,
    required this.isPrimitive,
    this.generics = const [],
    this.parent,
    this.isOptional = false,
  }) {
    for (final generic in generics) {
      generic.parent = this;
    }
  }

  @override
  List<Object> get props => [name, generics, isPrimitive, isOptional, displayName];

  FieldType copyWith({
    String? name,
    List<FieldType>? generics,
    bool? isPrimitive,
    String? displayName,
  }) {
    return FieldType(
      name: name ?? this.name,
      generics: generics ?? this.generics,
      isPrimitive: isPrimitive ?? this.isPrimitive,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  String toString() =>
      'FieldType(name: $name, displayName: $displayName, isPrimitive: $isPrimitive, optional: $isOptional, generic: $generics)';
}
