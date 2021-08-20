import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:serdes_json/serdes_json.dart';
import 'package:serdes_json_generator/parser.dart';
import 'package:source_gen/source_gen.dart';
import 'package:recase/recase.dart';

import 'models.dart';

class SerdesJsonGenerator extends GeneratorForAnnotation<SerdesJson> {
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
      } else if (type.name == 'List' && _isEnum(type.generics[0])) {
        final acceptable = '${type.generics[0].displayName}.acceptable';

        result += '\n';
        result += '    for (final value in $fieldName) {\n';
        result +=
            '      require($acceptable.contains(value), () => SchemeConsistencyException(\'"$fieldName" has a wrong value = \$value; acceptable values is: \${$acceptable}\'));\n';
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

      if (!type.optional) {
        result += '    required this.${field.name},\n';
      } else {
        result += 'this.${field.name},\n';
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

      final writer = _writer(type, fieldName);
      result += '    \$result[\'$jsonFieldName\'] = $writer;\n';
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
    return '  static $name fromStringJson(String json) => $name.fromJson(jsonDecode(json) as Map<String, dynamic>);';
  }

  String _writer(FieldType type, String fieldName) {
    if (type.isPrimitive) {
      return fieldName;
    } else if (type.generics.isEmpty) {
      if (type.optional) {
        return '$fieldName?.toJson()';
      } else {
        return '$fieldName.toJson()';
      }
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
        if (type.optional) {
          return '$fieldName?.map<String, dynamic>((key, value) => MapEntry<String, dynamic>(key, $value))';
        } else {
          return '$fieldName.map<String, dynamic>((key, value) => MapEntry<String, dynamic>(key, $value))';
        }
      }
    } else if (type.name == 'List') {
      final subType = type.generics[0];

      if (subType.isPrimitive || _isEnum(subType)) {
        return '$fieldName.toList()';
      } else if (type.optional) {
        if (subType.optional) {
          return '$fieldName?.map((it) => it?.toJson()).toList()';
        } else {
          return '$fieldName?.map((it) => it.toJson()).toList()';
        }
      } else {
        if (subType.optional) {
          return '$fieldName.map((it) => it?.toJson()).toList()';
        } else {
          return '$fieldName.map((it) => it.toJson()).toList()';
        }
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
      if (type.isPrimitive) {
        if (type.optional) {
          accessor = 'getJsonMapOrNull<dynamic>(json, \'$jsonFieldName\')';
        } else {
          accessor = 'getJsonMapOrNull<dynamic>(json, \'$jsonFieldName\')';
        }
      } else if (type.optional) {
        if (type.generics[1].optional) {
          accessor = 'getJsonMapOrNull<Map<String, dynamic>?>(json, \'$jsonFieldName\')';
        } else {
          accessor = 'getJsonMapOrNull<Map<String, dynamic>>(json, \'$jsonFieldName\')';
        }
      } else {
        if (type.generics[1].optional) {
          accessor = 'getJsonMap<Map<String, dynamic>?>(json, \'$jsonFieldName\')';
        } else {
          accessor = 'getJsonMap<Map<String, dynamic>>(json, \'$jsonFieldName\')';
        }
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
    } else if (type.name == 'Map') {
      final keyType = type.generics[0];
      final valueType = type.generics[1];

      if (keyType.name != 'String') {
        throw UnsupportedError('Unsupported type: $fieldName');
      }

      if (valueType.isPrimitive || valueType.name == 'dynamic') {
        final mapAccessor = type.optional ? '$accessor?' : accessor;
        return '$mapAccessor.map<String, ${valueType.displayName}>((key, dynamic value) => MapEntry<String, ${valueType.displayName}>(key, value as ${valueType.displayName}))';
      } else {
        final mapAccessor = type.optional ? '$accessor?' : accessor;
        final value = _accessor(valueType, null, 'value');

        if (valueType.optional) {
          return '$mapAccessor.map<String, ${valueType.displayName}>((key, Map<String, dynamic>? value) => MapEntry<String, ${valueType.displayName}>(key, value == null ? null : $value))';
        } else {
          return '$mapAccessor.map<String, ${valueType.displayName}>((key, Map<String, dynamic> value) => MapEntry<String, ${valueType.displayName}>(key, $value))';
        }
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

  bool _isEnum(FieldType type) {
    return type.generics.isEmpty && type.displayName.startsWith('Enum');
  }
}
