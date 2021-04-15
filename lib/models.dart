import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class FieldType extends Equatable {
  FieldType? parent;
  final String name;
  final List<FieldType> generics;
  final bool isPrimitive;
  final String displayName;
  final bool optional;

  FieldType({
    required this.name,
    required this.displayName,
    required this.isPrimitive,
    this.generics = const [],
    this.parent,
    this.optional = false,
  }) {
    for (final generic in generics) {
      generic.parent = this;
    }
  }

  @override
  List<Object> get props => [name, generics, isPrimitive, optional, displayName];

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
      'FieldType(name: $name, displayName: $displayName, isPrimitive: $isPrimitive, optional: $optional, generic: $generics)';
}
