import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:serdes_json_generator/models.dart';
import 'package:serdes_json_generator/parser.dart';
import 'package:serdes_json_generator/serdes_generator.dart';

void main() {
  final primitivesFields = <Field>[
    Field('v1', parseType('int')),
    Field('v2', parseType('int?')),
    Field('v3', parseType('String')),
    Field('v4', parseType('String?')),
  ];

  test('generateClassFields - primitivesFields', () async {
    final fields = SerdesGenerator().generateClass('TestScheme', 'Test', primitivesFields);
    final file = File('test_resources/generate_primitives_fields.dart');
    expect(fields, await file.readAsString());
  });
}
