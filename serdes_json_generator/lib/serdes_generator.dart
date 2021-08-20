import 'models.dart';
import 'package:recase/recase.dart';

class SerdesGenerator {
  final bool shouldConvertToSnakeCase;
  final bool shouldGenerateToJson;
  final bool shouldGenerateFromJson;
  final bool shouldGenerateToStringJson;
  final bool shoudlGenerateFromStringJson;

  SerdesGenerator({
    this.shouldConvertToSnakeCase = false,
    this.shouldGenerateToJson = true,
    this.shouldGenerateFromJson = true,
    this.shouldGenerateToStringJson = true,
    this.shoudlGenerateFromStringJson = true,
  });

  String generateClass(String originalClassName, String name, Iterable<Field> fields) {
    final result = StringBuffer();

    result.writeln('class $name {');
    result.writeln('  final $originalClassName? \$scheme = null;');
    result.writeln();

    result.write(generateClassFields(fields));
    result.writeln();
    result.write(generateConstructor(name, fields));

    if (shouldGenerateFromJson) {
      result.writeln();
      result.write(generateFromJson(name, fields));
    }

    if (shoudlGenerateFromStringJson) {
      result.writeln();
      result.write(generateFromJsonString(name));
    }

    if (shouldGenerateToJson) {
      result.writeln();
      result.write(generateToJson(name, fields));
    }

    if (shouldGenerateToStringJson) {
      result.writeln();
      result.write(generateToJsonString());
    }

    result.writeln('}');
    return result.toString();
  }

  String generateClassFields(Iterable<Field> fields) {
    final result = StringBuffer();

    for (final field in fields) {
      if (_isEnum(field.type)) {
        result.writeln('  final String ${field.name};');
      } else if (field.type.generics.length == 1 && _isEnum(field.type.generics[0])) {
        result.writeln('  final ${field.type.name}<String> ${field.name};');
      } else {
        result.writeln('  final ${field.type.displayName} ${field.name};');
      }
    }

    return result.toString();
  }

  String generateConstructor(String name, Iterable<Field> fields) {
    final result = StringBuffer();

    result.writeln('  $name({');

    for (final field in fields) {
      if (!field.type.isOptional) {
        result.writeln('    required this.${field.name},');
      } else {
        result.writeln('    this.${field.name},');
      }
    }

    result.writeln('  });');
    return result.toString();
  }

  String generateFromJson(String name, Iterable<Field> fields) {
    final result = StringBuffer();

    result.writeln('  $name.fromJson(Map<String, dynamic> json)');
    result.write('      : ');

    final margin = ' ' * 8;

    for (final field in fields) {
      result.writeln('${field.name} = ' + _jsonMapGetter(field.type, field.name) + ',');
      result.write(margin);
    }

    // Remove last margin and last comma
    final fromJson = result.toString().substring(0, result.length - margin.length - 2);
    result.clear();
    result.write(fromJson);
    result.writeln();
    result.writeln('  {');
    result.write(generateValidators(fields));
    result.writeln('  }');
    return result.toString();
  }

  String generateFromJsonString(String name) =>
      '  static $name fromStringJson(String json) => $name.fromJson(jsonDecode(json) as Map<String, dynamic>);\n';

  String generateValidators(Iterable<Field> fields) {
    final result = StringBuffer();
    return result.toString();
  }

  String generateToJson(String name, Iterable<Field> fields) {
    final result = StringBuffer();

    result.writeln('  Map<String, dynamic> toJson() {');
    result.writeln('    final \$result = <String, dynamic>{};');
    result.writeln();

    for (final field in fields) {
      final String jsonFieldName;

      if (shouldConvertToSnakeCase) {
        jsonFieldName = field.name.snakeCase;
      } else {
        jsonFieldName = field.name;
      }

      final writer = _jsonMapWriter(field.type, field.name);
      result.writeln('    \$result[\'$jsonFieldName\'] = $writer;');
    }

    result.writeln();
    result.writeln('    return \$result;');
    result.writeln('  }');

    return result.toString();
  }

  String generateToJsonString() => '  String toStringJson() => jsonEncode(toJson());\n';

  bool _isEnum(FieldType type) => type.generics.isEmpty && type.displayName.startsWith('Enum');

  String _jsonMapGetter(FieldType type, String? fieldName) {
    final typeName = type.displayName;
    String? jsonFieldName = fieldName;

    if (shouldConvertToSnakeCase && fieldName != null) {
      jsonFieldName = fieldName.snakeCase;
    }

    if (type.isPrimitive) {
      if (type.isOptional) {
        return 'getJsonValueOrNull(json, \'$jsonFieldName\')';
      } else {
        return 'getJsonValue(json, \'$jsonFieldName\')';
      }
    } else if (type.generics.isEmpty) {
      final args =
          'json, \'$jsonFieldName\', (Map<String, dynamic> data) => ${type.name}.fromJson(data)';

      if (type.isOptional) {
        return 'transformJsonValueOrNull<${type.name}, Map<String, dynamic>>($args)';
      } else {
        return 'transformJsonValue<${type.name}, Map<String, dynamic>>($args)';
      }
    } else {
      throw UnsupportedError('Unsupported type: $typeName');
    }
  }

  String _jsonMapWriter(FieldType type, String fieldName) {
    if (type.isPrimitive) {
      return fieldName;
    } else if (type.generics.isEmpty) {
      if (type.isOptional) {
        return '$fieldName?.toJson()';
      } else {
        return '$fieldName.toJson()';
      }
    } else {
      throw UnsupportedError('Unsupported type: $fieldName');
    }
  }
}
