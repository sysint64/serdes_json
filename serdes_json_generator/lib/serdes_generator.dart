import 'package:serdes_json_generator/parser.dart';

import 'models.dart';

class SerdesGenerator {
  final bool shouldGenerateToJson;
  final bool shouldGenerateFromJson;
  final bool shouldGenerateToStringJson;
  final bool shoudlGenerateFromStringJson;

  SerdesGenerator({
    this.shouldGenerateToJson = true,
    this.shouldGenerateFromJson = true,
    this.shouldGenerateToStringJson = true,
    this.shoudlGenerateFromStringJson = true,
  });

  String generateEnum(
    String enumName,
    Iterable<Field> fields,
  ) {
    final result = StringBuffer();
    final enumFields = fields.whereType<EnumField>();
    final supportedValues = enumFields.map((it) {
      if (it.valueType.displayName == 'String') {
        return '\\\'${it.value}\\\'';
      } else {
        return it.value;
      }
    }).join(',');

    result.writeln('abstract class _\$SerdesJson_${enumName}TypeAdapter {');

    if (shouldGenerateFromJson) {
      result.writeln('  static $enumName fromJson(String fieldName, dynamic json) {');
      result.writeln('    final value = fromJsonNullable(fieldName, json);');
      result.writeln('    if (value == null) {');
      result.writeln(
        '      throw SchemeConsistencyException(\'field: "\$fieldName" can\\\'t be null\');',
      );
      result.writeln('    } else {');
      result.writeln('      return value;');
      result.writeln('    }');
      result.writeln('  }');
      result.writeln();

      ///
      result.writeln('  static $enumName? fromJsonNullable(String fieldName, dynamic json) {');
      result.writeln('    if (json == null) {');
      result.writeln('      return null;');
      result.writeln('    }');
      result.write('    ');

      for (final field in enumFields) {
        if (field.valueType.displayName == 'String') {
          result.writeln('if (json == \'${field.value}\') {');
        } else {
          result.writeln('if (json == ${field.value}) {');
        }

        result.writeln('      return $enumName.${field.name};');
        result.write('    } else ');
      }

      result.writeln('{');
      result.writeln(
        '      throw SchemeConsistencyException(\'Unsupported "$enumName" value: \$json for field "\$fieldName". Supported values: $supportedValues\');',
      );
      result.writeln('    }');

      result.writeln('  }');

      if (shouldGenerateToJson) {
        result.writeln();
      }
    }

    if (shouldGenerateToJson) {
      result.writeln('  static dynamic toJson(String fieldName, $enumName object) {');
      result.writeln('    final value = toJsonNullable(object);');
      result.writeln('    if (value == null) {');
      result.writeln(
        '      throw SchemeConsistencyException(\'field: "\$fieldName" can\\\'t be null\');',
      );
      result.writeln('    } else {');
      result.writeln('      return value;');
      result.writeln('    }');
      result.writeln('  }');
      result.writeln();

      ///
      result.writeln('  static dynamic toJsonNullable($enumName? object) {');
      result.writeln('    if (object == null) {');
      result.writeln('      return null;');
      result.writeln('    }');
      result.writeln('    switch (object) {');

      for (final field in fields.whereType<EnumField>()) {
        result.writeln('      case $enumName.${field.name}:');

        if (field.valueType.displayName == 'String') {
          result.writeln('        return \'${field.value}\';');
        } else {
          result.writeln('        return ${field.value};');
        }
      }

      result.writeln('    }');
      result.writeln('  }');
    }

    result.writeln('}');

    return result.toString();
  }

  String generateClass(
    String originalClassName,
    String name,
    Iterable<Field> fields, [
    Iterable<FieldType> interfaces = const [],
  ]) {
    final result = StringBuffer();

    if (name.startsWith('_')) {
      name = name.substring(1);
    }

    if (interfaces.isNotEmpty) {
      final implements = interfaces.map((it) => it.displayName).join(', ');
      result.writeln('class $name implements $implements {');
    } else {
      result.writeln('class $name {');
    }

    result.writeln('  final $originalClassName? \$scheme = null;');
    result.writeln();

    result.write(generateClassFields(fields));
    result.writeln();
    result.write(generateConstructor(name, fields));
    result.write(generateUnions(fields));
    result.write(generateTypeAdapters(fields));

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

  String generateUnions(Iterable<Field> fields) {
    final result = StringBuffer();
    final unionFields = fields.whereType<UnionField>();

    for (final field in unionFields) {
      result.writeln();
      final targetFields = fields.where((it) => it.jsonName == field.union);

      if (targetFields.isEmpty) {
        throw StateError(
            'Couldn\'t find union field in shceme "${field.union}" for "${field.jsonName}" field');
      }

      final targetField = targetFields.first;

      result.writeln(
        '  static ${field.type.displayName} _\$createUnion\$${field.name}(Map<String, dynamic> json) {',
      );
      result.writeln(
        '    final union = ' +
            _jsonGetter(targetField.type, targetField.jsonName, 'json') +
            '.toString();',
      );
      result.writeln('    final content = ' +
          _jsonGetter(parseType('Map<String, dynamic>'), field.jsonName, 'json') +
          ';');
      result.writeln();
      result.write('    ');

      for (final value in field.unionValues) {
        result.writeln('if (union == \'${value.value}\') {');
        result.writeln('      return ${value.type.displayName}.fromJson(content);');
        result.write('    } else ');
      }

      result.writeln('{');
      final supportedTypes = field.unionValues.map((it) => it.value).join(',');
      result.writeln(
        '      throw SchemeConsistencyException(\'Unsupported "${field.union}" value: \$union. Supported values: $supportedTypes\');',
      );
      result.writeln('    }');

      result.writeln('  }');
    }

    return result.toString();
  }

  String generateTypeAdapters(Iterable<Field> fields) {
    final result = StringBuffer();
    final typeAdapterFields = fields.whereType<TypeAdapterField>();

    for (final field in typeAdapterFields) {
      result.writeln();
      result.writeln(
        '  static ${field.type.displayName} _\$createTypeAdapter\$${field.name}(Map<String, dynamic> json) {',
      );

      result.writeln(
        '    final object = ' + _jsonGetter(field.jsonContentType, field.jsonName, 'json') + ';',
      );
      result.writeln(
        '    return const ' + field.adapterType.displayName + '().fromJson(object);',
      );

      result.writeln('  }');
    }

    return result.toString();
  }

  String generateFromJson(String name, Iterable<Field> fields) {
    final result = StringBuffer();

    result.writeln('  $name.fromJson(Map<String, dynamic> json)');
    result.write('      : ');

    final margin = ' ' * 8;

    for (final field in fields) {
      if (field is UnionField) {
        result.writeln('${field.name} = _\$createUnion\$${field.name}(json),');
        result.write(margin);
      } else if (field is TypeAdapterField) {
        result.writeln('${field.name} = _\$createTypeAdapter\$${field.name}(json),');
        result.write(margin);
      } else {
        result.writeln('${field.name} = ' + _jsonGetter(field.type, field.jsonName, 'json') + ',');
        result.write(margin);
      }
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
      if (field is TypeAdapterField) {
        result.writeln(
          '    \$result[\'${field.jsonName}\'] = const ${field.adapterType.displayName}().toJson(${field.name});',
        );
      } else {
        final writer = _jsonSetter(field.type, field.name, field.jsonName);
        result.writeln('    \$result[\'${field.jsonName}\'] = $writer;');
      }
    }

    result.writeln();
    result.writeln('    return \$result;');
    result.writeln('  }');

    return result.toString();
  }

  String generateToJsonString() => '  String toStringJson() => jsonEncode(toJson());\n';

  bool _isEnum(FieldType type) => type.generics.isEmpty && type.displayName.startsWith('Enum');

  String _jsonGetter(FieldType type, String fieldName, String json) {
    final typeName = type.displayName;

    if (type.isEnum) {
      final getter = _jsonPrimitiveGetter(parseType('dynamic'), fieldName, json);
      if (type.isOptional) {
        return '_\$SerdesJson_${type.name}TypeAdapter.fromJsonNullable(\'$fieldName\', $getter)';
      } else {
        return '_\$SerdesJson_${type.name}TypeAdapter.fromJson(\'$fieldName\', $getter)';
      }
    } else if (type.isPrimitive) {
      return _jsonPrimitiveGetter(type, fieldName, json);
    } else if (type.generics.isEmpty) {
      return _jsonSchemeGetter(type, fieldName, json);
    } else if (type.name == 'List') {
      return _jsonListGetter(type, fieldName, json);
    } else if (type.name == 'Map') {
      return _jsonMapGetter(type, fieldName, json);
    } else {
      throw UnsupportedError('Unsupported type: $typeName for field: $fieldName');
    }
  }

  String _fromJsonItemConstructor(FieldType type, String it, String fieldName) {
    if (type.name == 'dynamic') {
      return it;
    } else if (type.isPrimitive) {
      return '$it as ${type.displayName}';
    } else if (type.generics.isEmpty) {
      if (type.isOptional) {
        return '$it == null ? null : ${type.name}.fromJson($it as Map<String, dynamic>)';
      } else {
        return '${type.name}.fromJson($it as Map<String, dynamic>)';
      }
    } else if (type.name == 'List') {
      if (type.generics.length != 1) {
        throw UnsupportedError(
            'Unsupported type: $type  for field: $fieldName, please specify generic type');
      }

      final subType = type.generics[0];
      final itemConstructor = _fromJsonItemConstructor(subType, 'it', fieldName);

      if (subType.name == 'dynamic') {
        return '($it as Iterable<dynamic>).toList()';
      } else {
        if (subType.isOptional) {
          return '($it as Iterable<dynamic>).map((dynamic it) => it == null ? null : $itemConstructor).toList()';
        } else {
          return '($it as Iterable<dynamic>).map((dynamic it) => $itemConstructor).toList()';
        }
      }
    } else if (type.name == 'Map') {
      if (type.generics.length != 2) {
        throw UnsupportedError(
            'Unsupported type: ${type.displayName} for field: $fieldName, please specify generic types');
      }

      final keyType = type.generics[0];
      final valueType = type.generics[1];

      if (keyType.name != 'String') {
        throw UnsupportedError(
            'Unsupported type: ${type.displayName} for field: $fieldName, only String type allowed as a Map key');
      }

      if (valueType.name == 'dynamic') {
        return '$it as Map<String, dynamic>';
      } else {
        final itemConstructor = _fromJsonItemConstructor(valueType, 'value', fieldName);
        final mapEntry = 'MapEntry<String, ${valueType.displayName}>';
        final String map;

        if (valueType.isOptional) {
          map =
              '(String key, dynamic value) => value == null ? $mapEntry(key, null) : $mapEntry(key, $itemConstructor)';
        } else {
          map = '(String key, dynamic value) => $mapEntry(key, $itemConstructor)';
        }

        return '($it as Map<String, dynamic>).map<String, ${valueType.displayName}>($map)';
      }
    } else {
      throw UnsupportedError('Unsupported type: ${type.displayName} for field: $fieldName');
    }
  }

  String _jsonPrimitiveGetter(FieldType type, String fieldName, String json) {
    if (type.isOptional) {
      return 'getJsonValueOrNull<${type.name}>($json, \'$fieldName\')';
    } else {
      return 'getJsonValue<${type.name}>($json, \'$fieldName\')';
    }
  }

  String _jsonSchemeGetter(FieldType type, String fieldName, String json) {
    final args = '$json, \'$fieldName\', (Map<String, dynamic> it) => ${type.name}.fromJson(it)';

    if (type.isOptional) {
      return 'transformJsonValueOrNull<${type.name}, Map<String, dynamic>>($args)';
    } else {
      return 'transformJsonValue<${type.name}, Map<String, dynamic>>($args)';
    }
  }

  String _jsonListGetter(FieldType type, String fieldName, String json) {
    if (type.generics.length != 1) {
      throw UnsupportedError(
          'Unsupported type: $fieldName for field: $fieldName, please specify generic type');
    }

    final subType = type.generics[0];
    final itemConstructor = _fromJsonItemConstructor(subType, 'it', fieldName);

    if (subType.name == 'dynamic') {
      if (type.isOptional) {
        return 'getJsonValueOrNull<List<dynamic>>($json, \'$fieldName\')';
      } else {
        return 'getJsonValue<List<dynamic>>($json, \'$fieldName\')';
      }
    } else {
      if (type.isOptional) {
        return 'transformJsonListOfMapOrNull<${subType.displayName}, dynamic>($json, \'$fieldName\', (dynamic it) => $itemConstructor)';
      } else {
        return 'transformJsonListOfMap<${subType.displayName}, dynamic>($json, \'$fieldName\', (dynamic it) => $itemConstructor)';
      }
    }
  }

  String _jsonMapGetter(FieldType type, String fieldName, String json) {
    if (type.generics.length != 2) {
      throw UnsupportedError(
          'Unsupported type: ${type.displayName} for field: $fieldName, please specify generic types');
    }

    final keyType = type.generics[0];
    final valueType = type.generics[1];

    if (keyType.name != 'String') {
      throw UnsupportedError(
          'Unsupported type: ${type.displayName} for field: $fieldName, only String type allowed as a Map key');
    }

    final itemConstructor = _fromJsonItemConstructor(valueType, 'value', fieldName);
    final mapEntry = 'MapEntry<String, ${valueType.displayName}>';
    final map = '$mapEntry(key, $itemConstructor)';

    // if (valueType.isOptional) {
    //   map = 'value == null ? $mapEntry(key, null) : $mapEntry(key, $itemConstructor)';
    // } else {
    //   map = '$mapEntry(key, $itemConstructor)';
    // }

    if (type.isOptional) {
      return 'getJsonValueOrNull<Map<String, dynamic>>($json, \'$fieldName\')?.map<String, ${valueType.displayName}>((String key, dynamic value) => $map)';
    } else {
      final String map = '$mapEntry(key, $itemConstructor)';
      return 'getJsonValue<Map<String, dynamic>>($json, \'$fieldName\').map<String, ${valueType.displayName}>((String key, dynamic value) => $map)';
    }
  }

  String _jsonSetter(FieldType type, String fieldName, [String? jsonName]) {
    if (type.isEnum) {
      if (type.isOptional) {
        return '_\$SerdesJson_${type.name}TypeAdapter.toJsonNullable($fieldName)';
      } else {
        return '_\$SerdesJson_${type.name}TypeAdapter.toJson(\'${jsonName ?? fieldName}\', $fieldName)';
      }
    } else if (type.isPrimitive) {
      return fieldName;
    } else if (type.generics.isEmpty) {
      if (type.isOptional) {
        return '$fieldName?.toJson()';
      } else {
        return '$fieldName.toJson()';
      }
    } else if (type.name == 'List') {
      if (type.generics.length != 1) {
        throw UnsupportedError(
            'Unsupported type: $fieldName for field: $fieldName, please specify generic type');
      }

      final subType = type.generics[0];
      final itemConstructor = _jsonSetter(subType, 'it');

      if (subType.name == 'dynamic') {
        return fieldName;
      } else if (type.isOptional) {
        return '$fieldName?.map<dynamic>((${subType.displayName} it) => $itemConstructor).toList()';
      } else {
        return '$fieldName.map<dynamic>((${subType.displayName} it) => $itemConstructor).toList()';
      }
    } else if (type.name == 'Map') {
      if (type.generics.length != 2) {
        throw UnsupportedError(
            'Unsupported type: ${type.displayName} for field: $fieldName, please specify generic types');
      }

      final keyType = type.generics[0];
      final valueType = type.generics[1];
      final itemConstructor = _jsonSetter(valueType, 'value');

      if (keyType.name != 'String') {
        throw UnsupportedError(
            'Unsupported type: ${type.displayName} for field: $fieldName, only String type allowed as a Map key');
      }

      final mapEntry = 'MapEntry<String, dynamic>';

      if (valueType.name == 'dynamic') {
        return fieldName;
      } else if (type.isOptional) {
        return '$fieldName?.map<String, dynamic>((String key, ${valueType.displayName} value) => $mapEntry(key, $itemConstructor))';
      } else {
        return '$fieldName.map<String, dynamic>((String key, ${valueType.displayName} value) => $mapEntry(key, $itemConstructor))';
      }
    } else {
      throw UnsupportedError('Unsupported type: ${type.name}');
    }
  }
}
