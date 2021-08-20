import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:serdes_json/serdes_json.dart';
import 'package:serdes_json_generator/parser.dart';
import 'package:source_gen/source_gen.dart';
import 'package:recase/recase.dart';

import 'models.dart';

class JsonSerializableGenerator extends GeneratorForAnnotation<SerdesJson> {
  bool _convertToSnakeCase = false;
  bool _generateToJson = true;
  bool _generateFromJson = true;
  bool _generateToStringJson = true;
  bool _generateFromStringJson = true;

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
    _convertToSnakeCase = annotation.read('convertToSnakeCase').literalValue as bool;
    _generateToJson = annotation.read('toJson').literalValue as bool;
    _generateFromJson = annotation.read('fromJson').literalValue as bool;
    _generateToStringJson = annotation.read('toStringJson').literalValue as bool;
    _generateFromStringJson = annotation.read('fromStringJson').literalValue as bool;

    var name = classElement.name;

    if (name.endsWith('Scheme')) {
      name = name.substring(0, name.length - 'Scheme'.length);
    } else {
      name = '${name}Response';
    }

    String result = 'class $name {\n';
    result += '  final ${classElement.name}? \$scheme = null;';

    for (final field in classElement.fields) {
      final type = parseType(field.type.toString());
      final fieldName = field.name;

      if (_isEnum(type)) {
        result += '  final String $fieldName;\n';
      } else if (type.generics.length == 1 && _isEnum(type.generics[0])) {
        result += '  final ${type.name}<String> $fieldName;\n';
      } else if (type.name == 'Optional' &&
          type.generics[0].name == 'List' &&
          _isEnum(type.generics[0].generics[0])) {
        result += '  final Optional<List<String>> $fieldName;\n';
      } else {
        result += '  final ${type.displayName} $fieldName;\n';
      }
    }

    result += '\n';
    result += _constructor(classElement, name);
    result += '\n';

    if (_generateFromJson) {
      result += _fromJsonFactory(classElement, name);
      result += '\n';
      result += '  {\n';
      result += _validators(classElement);
      result += '  }\n';
      result += '\n';
    }

    if (_generateToJson) {
      result += _toJson(classElement, name);
      result += '\n';
    }

    if (_generateToStringJson) {
      result += _toStringJson();
      result += '\n';
    }

    if (_generateFromStringJson) {
      result += _fromStringJson(name);
    }

    result += '}';

//    var commentted = '';
//
//    for (final line in result.split('\n')) {
//      commentted += '// $line\n';
//    }

    return result;
  }

  String _validators(ClassElement classElement) {
    String result = '';

    final validate = classElement.methods.firstWhereOrNull((it) => it.name == 'validate');

    if (validate != null) {
      result += '    ${classElement.name}.validate(this);\n';
    }

    for (final field in classElement.fields) {
      final fieldName = field.name;
      final type = parseType(field.type.toString());

      if (type.optional && _isEnum(type)) {
        final acceptable = '${type.displayName}.acceptable';

        result += '\n';
        result += '    if ($fieldName != null) {\n';
        result += '      final value = $fieldName!;\n';
        result +=
            '      require($acceptable.contains(value), () => SchemeConsistencyException(\'"$fieldName" has a wrong value = \$value; acceptable values is: \${$acceptable}\'));\n';
        result += '    }\n';
        result += '\n';
      } else if (_isEnum(type)) {
        final acceptable = '${type.displayName}.acceptable';
        result +=
            '    require($acceptable.contains($fieldName), () => SchemeConsistencyException(\'"$fieldName" has a wrong value = \$$fieldName; acceptable values is: \${$acceptable}\'));\n';
      } else if (type.name == 'Optional' && _isEnum(type.generics[0])) {
        final acceptable = '${type.generics[0].displayName}.acceptable';

        result += '\n';
        result += '    if ($fieldName.isPresent) {\n';
        result += '      final value = $fieldName.value;\n';
        result +=
            '      require($acceptable.contains(value), () => SchemeConsistencyException(\'"$fieldName" has a wrong value = \$value; acceptable values is: \${$acceptable}\'));\n';
        result += '    }\n';
        result += '\n';
      } else if (type.name == 'List' && _isEnum(type.generics[0])) {
        final acceptable = '${type.generics[0].displayName}.acceptable';

        result += '\n';
        result += '    for (final value in $fieldName) {\n';
        result +=
            '      require($acceptable.contains(value), () => SchemeConsistencyException(\'"$fieldName" has a wrong value = \$value; acceptable values is: \${$acceptable}\'));\n';
        result += '    }\n';
        result += '\n';
      } else if (type.name == 'Optional' &&
          type.generics[0].name == 'List' &&
          _isEnum(type.generics[0].generics[0])) {
        final acceptable = '${type.generics[0].generics[0].displayName}.acceptable';

        result += '\n';
        result += '    if ($fieldName.isPresent) {\n';
        result += '      for (final value in $fieldName.value) {\n';
        result +=
            '        require($acceptable.contains(value), () => SchemeConsistencyException(\'"$fieldName" has a wrong value = \$value; acceptable values is: \${$acceptable}\'));\n';
        result += '      }\n';
        result += '    }\n';
        result += '\n';
      }
    }

    return result;
  }

  String _constructor(ClassElement classElement, String name) {
    String result = '';

    result += '  $name({\n';

    for (final field in classElement.fields) {
      final type = parseType(field.type.toString());

      if (type.name == 'Optional') {
        result += '    this.${field.name} = const Optional.empty(),\n';
      } else {
        result += '    required this.${field.name},\n';
      }
    }

    result += '  });\n';
    return result;
  }

  String _toJson(ClassElement classElement, String name) {
    String result = '';

    result += '  Map<String, dynamic> toJson() {\n';
    result += '    final \$result = <String, dynamic>{};\n';
    result += '\n';

    for (final field in classElement.fields) {
      final fieldName = field.name;
      final typeName = field.type.toString();
      var type = parseType(typeName);

      String jsonFieldName = fieldName;

      if (_convertToSnakeCase) {
        jsonFieldName = fieldName.snakeCase;
      }

      if (_isEnum(type)) {
        type = FieldType(
          name: 'String',
          displayName: 'String',
          isPrimitive: true,
        );
      }

      if (type.name == 'Optional') {
        var optionalType = type.generics[0];

        if (_isEnum(optionalType)) {
          optionalType = FieldType(
            name: 'String',
            displayName: 'String',
            isPrimitive: true,
          );
        }

        final writer = _writerOptional(optionalType, fieldName);

        result += '\n';
        result += '    if ($fieldName.isPresent) {\n';
        result += '      \$result[\'$jsonFieldName\'] = $writer;\n';
        result += '    }\n';
        result += '\n';
      } else {
        final writer = _writer(type, fieldName);
        result += '    \$result[\'$jsonFieldName\'] = $writer;\n';
      }
    }

    result += '\n';
    // ignore: use_raw_strings
    result += '    return \$result;';
    result += '  }\n';

    return result;
  }

  String _toStringJson() {
    return '  String toStringJson() => jsonEncode(toJson());';
  }

  String _fromStringJson(String name) {
    return '  static $name fromStringJson(String json) => $name.fromJson(jsonDecode(json));';
  }

  String _writer(FieldType type, String fieldName) {
    if (type.isPrimitive) {
      return fieldName;
    } else if (type.generics.isEmpty) {
      return '$fieldName.toJson()';
    } else if (type.name == 'Optional') {
      throw StateError('Should not be used with Optional type');
    } else if (type.name == 'Map') {
      final keyType = type.generics[0];
      final valueType = type.generics[1];

      if (keyType.name != 'String') {
        throw UnsupportedError('Unsupported type: $fieldName');
      }

      if (valueType.isPrimitive || valueType.name == 'dynamic') {
        return fieldName;
      } else {
        final value = _writer(valueType, 'value');
        return '$fieldName.map((key, value) => MapEntry<String, dynamic>(key, $value))';
      }
    } else if (type.name == 'List') {
      final subType = type.generics[0];

      if (subType.isPrimitive || _isEnum(subType)) {
        return '$fieldName.toList()';
      } else {
        return '$fieldName.map((it) => it.toJson()).toList()';
      }
    } else {
      throw UnsupportedError('Unsupported type: $fieldName');
    }
  }

  String _writerOptional(FieldType type, String fieldName) {
    if (type.isPrimitive) {
      return '$fieldName.value';
    } else if (type.generics.isEmpty) {
      return '$fieldName.value.toJson()';
    } else if (type.name == 'Map') {
      final keyType = type.generics[0];
      final valueType = type.generics[1];

      if (keyType.name != 'String') {
        throw UnsupportedError('Unsupported type: $fieldName');
      }

      if (valueType.isPrimitive || valueType.name == 'dynamic') {
        return '$fieldName.value';
      } else {
        final value = _writer(valueType, 'value');
        return '$fieldName.value.map((key, value) => MapEntry<String, dynamic>(key, $value))';
      }
    } else if (type.name == 'List') {
      final subType = type.generics[0];

      if (subType.isPrimitive || _isEnum(subType)) {
        return '$fieldName.value.toList();';
      } else {
        return '$fieldName.value.map((it) => it.toJson()).toList();';
      }
    } else {
      throw UnsupportedError('Unsupported type: $fieldName');
    }
  }

  String _fromJsonFactory(ClassElement classElement, String name) {
    String result = '';

    result += '  $name.fromJson(Map<String, dynamic> json)\n';
    result += '      : ';
    final margin = ' ' * 8;

    for (final field in classElement.fields) {
      final fieldName = field.name;
      final typeName = field.type.toString();
      final type = parseType(typeName);

      // ignore: use_string_buffers, prefer_interpolation_to_compose_strings
      result += '$fieldName = ' + _accessor(type, fieldName) + ',\n';
      // ignore: use_string_buffers
      result += margin;
    }

    // Remove last margin and last comma
    // ignore: join_return_with_assignment
    result = result.substring(0, result.length - margin.length - 2);
    return result;
  }

  String _accessor(FieldType type, String? fieldName, [String? accessor]) {
    final typeName = type.displayName;

    String? jsonFieldName = fieldName;

    if (_convertToSnakeCase && fieldName != null) {
      jsonFieldName = fieldName.snakeCase;
    }

    if (accessor == null && type.name != 'Map') {
      if (type.optional) {
        accessor = 'getJsonValueOrNull(json, \'$jsonFieldName\')';
      } else {
        accessor = 'getJsonValue(json, \'$jsonFieldName\')';
      }
    } else if (accessor == null && type.name == 'Map') {
      if (type.optional) {
        // ignore: parameter_assignments
        accessor = 'getJsonMapOrNull(json, \'$jsonFieldName\')';
      } else {
        // ignore: parameter_assignments
        accessor = 'getJsonMap(json, \'$jsonFieldName\')';
      }
    }

    if (_isEnum(type)) {
      // ignore: parameter_assignments
      type = FieldType(
        name: 'String',
        displayName: 'String',
        isPrimitive: true,
      );
    }

    if (type.isPrimitive) {
      return accessor!;
    } else if (type.generics.isEmpty) {
      return '$typeName.fromJson($accessor)';
    } else if (type.name == 'Optional') {
      return _optionalAccessor(type.generics[0], fieldName);
    } else if (type.name == 'Map') {
      final keyType = type.generics[0];
      final valueType = type.generics[1];

      if (keyType.name != 'String') {
        throw UnsupportedError('Unsupported type: $fieldName');
      }

      if (valueType.isPrimitive || valueType.name == 'dynamic') {
        return '$accessor.map((key, value) => MapEntry<String, ${valueType.displayName}>(key, value as ${valueType.displayName}))';
      } else {
        final value = _accessor(valueType, null, 'value');
        return '$accessor.map((key, value) => MapEntry<String, ${valueType.displayName}>(key, $value))';
      }
    } else if (type.name == 'List') {
      final subType = type.generics[0];

      if (subType.isPrimitive || _isEnum(subType)) {
        String subTypeName;

        if (_isEnum(subType)) {
          subTypeName = 'String';
        } else {
          subTypeName = subType.displayName;
        }

        if (type.optional) {
          return 'getJsonListOrNull<$subTypeName>(json, \'$jsonFieldName\')';
        } else {
          return 'getJsonList<$subTypeName>(json, \'$jsonFieldName\')';
        }
      } else {
        final subAccessor = _accessor(type.generics[0], null, 'it');
        if (type.optional) {
          return 'transformJsonListOfMapOrNull(json, \'$jsonFieldName\', (it) => $subAccessor)';
        } else {
          return 'transformJsonListOfMap(json, \'$jsonFieldName\', (it) => $subAccessor)';
        }
      }
    } else {
      throw UnsupportedError('Unsupported type: $typeName');
    }
  }

  // TODO: merge with _accessor
  String _optionalAccessor(FieldType type, String? fieldName, [String? accessor]) {
    final typeName = type.displayName;

    String? jsonFieldName = fieldName;

    if (_convertToSnakeCase && fieldName != null) {
      jsonFieldName = fieldName.snakeCase;
    }

    accessor ??= 'getJsonValueOrEmpty(json, \'$jsonFieldName\')';

    if (type.isPrimitive || _isEnum(type)) {
      return accessor;
    } else if (type.generics.isEmpty) {
      final subAccessor = _accessor(type, null, 'it');
      return 'transformJsonValueOrEmpty(json, \'$jsonFieldName\', (it) => $subAccessor)';
    } else if (type.name == 'List') {
      final subType = type.generics[0];

      if (subType.isPrimitive || _isEnum(subType)) {
        String subTypeName;

        if (_isEnum(subType)) {
          subTypeName = 'String';
        } else {
          subTypeName = subType.displayName;
        }

        return 'getJsonListOrEmpty<$subTypeName>(json, \'$jsonFieldName\')';
      } else {
        final subAccessor = _accessor(type.generics[0], null, 'it');
        return 'transformJsonListOfMapOrEmpty(json, \'$jsonFieldName\', (it) => $subAccessor)';
      }
    } else {
      throw UnsupportedError('Unsupported type: $typeName');
    }
  }

  bool _isEnum(FieldType type) {
    return type.generics.isEmpty && type.displayName.startsWith('Enum');
  }
}
