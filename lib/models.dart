import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class FieldType extends Equatable {
  FieldType parent;
  final String name;
  final List<FieldType> generics;
  final bool isPrimitive;
  final String displayName;

  FieldType({
    this.name,
    this.displayName,
    this.isPrimitive,
    this.generics = const [],
    this.parent,
  })  : assert(name != null),
        assert(displayName != null),
        assert(generics != null),
        assert(isPrimitive != null) {
    for (final generic in generics) {
      generic.parent = this;
    }
  }

  @override
  List<Object> get props => [name, generics, isPrimitive, displayName];

  FieldType copyWith({
    String name,
    List<FieldType> generics,
    bool isPrimitive,
    String displayName,
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
      'FieldType(name: $name, displayName: $displayName, isPrimitive: $isPrimitive, generic: $generics)';
}
