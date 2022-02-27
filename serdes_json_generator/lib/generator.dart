import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:recase/recase.dart';
import 'package:serdes_json/adapter.dart';
import 'package:serdes_json/serdes_json.dart';
import 'package:serdes_json_generator/parser.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import 'models.dart';
import 'serdes_generator.dart';

final _jsonFieldChecker = const TypeChecker.fromRuntime(SerdesJsonField);
final _typeAdapterChecker = const TypeChecker.fromRuntime(SerdesJsonTypeAdapter);

class SerdesJsonGenerator extends GeneratorForAnnotation<SerdesJson> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      final name = element.name;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$name`.',
        todo: 'Remove the JsonSerializable annotation from `$name`.',
        element: element,
      );
    }

    final classElement = element;
    final convertToSnakeCase = annotation.read('convertToSnakeCase').literalValue as bool;
    final generateToJson = annotation.read('toJson').literalValue as bool;
    final generateFromJson = annotation.read('fromJson').literalValue as bool;
    final generateToStringJson = annotation.read('toStringJson').literalValue as bool;
    final generateFromStringJson = annotation.read('fromStringJson').literalValue as bool;
    final endsWith = annotation.read('endsWith').literalValue as String;

    var name = classElement.name;

    if (endsWith.isEmpty) {
      throw StateError('endWith can\'t be empty');
    }

    if (name.endsWith(endsWith)) {
      name = name.substring(0, name.length - endsWith.length);
    } else {
      throw StateError('Class name should end with "$endsWith"');
    }

    final classLevelAdapters = _typeAdapterChecker.annotationsOf(classElement);

    final fields = classElement.fields.map(
      (field) {
        final type = parseType(field.type.toString());
        final fieldAdapters = _typeAdapterChecker
            .annotationsOf(field)
            .map((it) => _isTypeAdapterValid(field.type, it))
            .where((it) => it != null)
            .map((it) => it!);

        final adapters = [
          ...fieldAdapters,
          ...classLevelAdapters
              .map((it) => _isTypeAdapterValid(field.type, it))
              .where((it) => it != null)
              .map((it) => it!),
        ];

        _TypeAdapterMatch? typeAdapter;

        if (adapters.isNotEmpty) {
          typeAdapter = adapters.first;
          // typeAdapter = parseType(adapters.first.fieldType.toString());
          // throw typeAdapter.displayName;
        }

        if (_jsonFieldChecker.hasAnnotationOfExact(field)) {
          final annotation = _jsonFieldChecker.firstAnnotationOfExact(field);
          final jsonName = annotation?.getField('name')?.toStringValue() ?? field.name;
          final unionName = annotation?.getField('union')?.toStringValue();
          final unionValues = annotation?.getField('unionValues')?.toListValue()?.map((it) {
            final value = it.getField('value')?.toStringValue();
            final type = it.getField('type')!.toTypeValue().toString();
            return FieldUnionData(value, parseType(type));
          }).toList();

          if (unionName != null && unionValues != null) {
            return UnionField(field.name, jsonName, type, unionName, unionValues);
          } else {
            return Field(field.name, convertToSnakeCase ? field.name.snakeCase : field.name, type);
          }
        } else if (typeAdapter != null) {
          return TypeAdapterField(
            field.name,
            convertToSnakeCase ? field.name.snakeCase : field.name,
            type,
            typeAdapter.fieldType,
            typeAdapter.jsonType,
          );
        } else {
          return Field(field.name, convertToSnakeCase ? field.name.snakeCase : field.name, type);
        }
      },
    );

    return SerdesGenerator(
      shouldGenerateToJson: generateToJson,
      shouldGenerateFromJson: generateFromJson,
      shouldGenerateToStringJson: generateToStringJson,
      shoudlGenerateFromStringJson: generateFromStringJson,
    ).generateClass(
      classElement.name,
      name,
      fields,
      classElement.interfaces.map((e) => parseType(e.toString())),
    );
  }
}

class _TypeAdapterMatch {
  final FieldType fieldType;
  final FieldType jsonType;

  _TypeAdapterMatch(
    this.fieldType,
    this.jsonType,
  );
}

_TypeAdapterMatch? _isTypeAdapterValid(DartType targetType, DartObject annotation) {
  final converterClassElement = annotation.type!.element as ClassElement;

  final jsonAdapterSuper = converterClassElement.allSupertypes.singleWhereOrNull(
    (e) => _typeAdapterChecker.isExactly(e.element),
  );

  if (jsonAdapterSuper == null) {
    return null;
  }

  assert(jsonAdapterSuper.element.typeParameters.length == 2);
  assert(jsonAdapterSuper.typeArguments.length == 2);

  final fieldType = jsonAdapterSuper.typeArguments[0];

  if (fieldType == targetType) {
    return _TypeAdapterMatch(
      parseType(fieldType.toString()),
      parseType(jsonAdapterSuper.typeArguments[1].toString()),
    );
  }

  return null;
  // return fieldType == targetType;
}

// _TypeAdapterMatch? _compatibleMatch(
//   DartType targetType,
//   ElementAnnotation annotation,
// ) {
//   final constantValue = annotation.computeConstantValue()!;
//   final converterClassElement = constantValue.type!.element as ClassElement;

//   final jsonAdapterSuper = converterClassElement.allSupertypes.singleWhereOrNull(
//     (e) => _typeAdapterChecker.isExactly(e.element),
//   );

//   if (jsonAdapterSuper == null) {
//     return null;
//   }

//   assert(jsonAdapterSuper.element.typeParameters.length == 2);
//   assert(jsonAdapterSuper.typeArguments.length == 2);

//   final fieldType = jsonAdapterSuper.typeArguments[0];

//   if (fieldType == targetType) {
//     return _TypeAdapterMatch(annotation, constantValue, jsonAdapterSuper.typeArguments[1], null);
//   }

//   // if (fieldType is TypeParameterType && targetType is TypeParameterType) {
//   //   assert(annotation.element is! PropertyAccessorElement);
//   //   assert(converterClassElement.typeParameters.isNotEmpty);
//   //   if (converterClassElement.typeParameters.length > 1) {
//   //     throw InvalidGenerationSourceError(
//   //       '`$SerdesJsonTypeAdapter` implementations can have no more than one type '
//   //       'argument. `${converterClassElement.name}` has '
//   //       '${converterClassElement.typeParameters.length}.',
//   //       element: converterClassElement,
//   //     );
//   //   }

//   //   return _ConverterMatch(
//   //     annotation,
//   //     constantValue,
//   //     jsonAdapterSuper.typeArguments[1],
//   //     '${targetType.element.name}${targetType.isNullableType ? '?' : ''}',
//   //   );
//   // }

//   return null;
// }
