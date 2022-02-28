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
final _jsonEnumFieldChecker = const TypeChecker.fromRuntime(SerdesJsonEnumField);
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

    if (element.isEnum) {
      return _generateEnum(element, annotation);
    } else {
      return _generateClass(element, annotation);
    }
  }

  String _generateEnum(
    ClassElement element,
    ConstantReader annotation,
  ) {
    final convertToSnakeCase = annotation.read('convertToSnakeCase').literalValue as bool;
    final generateToJson = annotation.read('toJson').literalValue as bool;
    final generateFromJson = annotation.read('fromJson').literalValue as bool;

    final dynamicType = parseType('dynamic');

    final fields = element.fields.where((it) => it.isEnumConstant).map(
      (field) {
        final fieldName = convertToSnakeCase ? field.name.snakeCase : field.name;

        if (_jsonEnumFieldChecker.hasAnnotationOfExact(field)) {
          final annotation = _jsonEnumFieldChecker.firstAnnotationOfExact(field);
          final value = annotation?.getField('value');

          if (value == null) {
            return Field(field.name, fieldName, dynamicType);
          }

          final valueType = parseType(value.type!.toString());
          final String enumValue;

          if (valueType.displayName == 'String') {
            enumValue = value.toStringValue()!;
          } else if (valueType.displayName == 'int') {
            enumValue = value.toIntValue()!.toString();
          } else if (valueType.displayName == 'double') {
            enumValue = value.toDoubleValue()!.toString();
          } else {
            throw StateError(
              'Unsupported enum value type: ${valueType.displayName}',
            );
          }

          return EnumField(field.name, enumValue, valueType);
        } else {
          return EnumField(field.name, fieldName, parseType('String'));
        }
      },
    );

    return SerdesGenerator(
      shouldGenerateToJson: generateToJson,
      shouldGenerateFromJson: generateFromJson,
    ).generateEnum(element.name, fields);
  }

  String _generateClass(
    ClassElement element,
    ConstantReader annotation,
  ) {
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
        final type = parseType(field.type.toString(), isEnum: field.type.isEnum);
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
          final fieldName = convertToSnakeCase ? field.name.snakeCase : field.name;
          final jsonName = annotation?.getField('name')?.toStringValue() ?? fieldName;
          final unionName = annotation?.getField('union')?.toStringValue();
          final unionValues = annotation?.getField('unionValues')?.toListValue()?.map((it) {
            final value = it.getField('value')?.toStringValue();
            final type = it.getField('type')!.toTypeValue().toString();
            return FieldUnionData(value, parseType(type));
          }).toList();

          if (unionName != null && unionValues != null) {
            return UnionField(field.name, jsonName, type, unionName, unionValues);
          } else {
            return Field(field.name, jsonName, type);
          }
        } else if (typeAdapter != null) {
          return TypeAdapterField(
            field.name,
            convertToSnakeCase ? field.name.snakeCase : field.name,
            type,
            typeAdapter.adapterType,
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
  final FieldType adapterType;
  final FieldType jsonType;

  _TypeAdapterMatch(
    this.adapterType,
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
      parseType(annotation.type!.toString()),
      parseType(jsonAdapterSuper.typeArguments[1].toString()),
    );
  }

  return null;
}
