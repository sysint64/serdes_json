import 'package:equatable/equatable.dart';
import 'package:serdes_json_generator/parser.dart';

class Field {
  final String name;
  final String jsonName;
  final FieldType type;

  const Field(this.name, this.jsonName, this.type);
}

class EnumField extends Field {
  final String value;
  final FieldType valueType;

  EnumField(String name, this.value, this.valueType)
      : super(name, '', parseType('dynamic'));
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
  final bool isEnum;

  FieldType({
    required this.name,
    required this.displayName,
    required this.isPrimitive,
    this.generics = const [],
    this.parent,
    this.isOptional = false,
    this.isEnum = false,
  }) {
    for (final generic in generics) {
      generic.parent = this;
    }
  }

  @override
  List<Object> get props => [name, generics, isPrimitive, isOptional, displayName];

  FieldType withEnum(bool newIsEnum) {
    return FieldType(
      isEnum: newIsEnum,
      name: name,
      displayName: displayName,
      isPrimitive: isPrimitive,
      generics: generics,
      parent: parent,
      isOptional: isOptional,
    );
  }

  @override
  String toString() =>
      'FieldType(name: $name, displayName: $displayName, isPrimitive: $isPrimitive, optional: $isOptional, generic: $generics)';
}
