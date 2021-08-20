import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:serdes_json_generator/models.dart';
import 'package:serdes_json_generator/parser.dart';
import 'package:serdes_json_generator/serdes_generator.dart';

void main() {
  test('genrate class - primitives', () async {
    final primitivesFields = <Field>[
      Field('v1', parseType('int')),
      Field('v2', parseType('int?')),
      Field('v3', parseType('String')),
      Field('v4', parseType('String?')),
    ];
    final result = SerdesGenerator().generateClass('TestScheme', 'Test', primitivesFields);
    final file = File('test_resources/generate_primitives_fields.dart');
    expect(result, await file.readAsString());
  });

  test('generate class - schemes', () async {
    final schemeFields = <Field>[
      Field('v1', parseType('User')),
      Field('v2', parseType('Book?')),
    ];
    final result = SerdesGenerator().generateClass('TestScheme', 'Test', schemeFields);
    final file = File('test_resources/generate_schemes_fields.dart');
    expect(result, await file.readAsString());
  });

  test('generate class - lists', () async {
    final schemeFields = <Field>[
      Field('v1', parseType('List<int>')),
      Field('v2', parseType('List<int?>')),
      Field('v3', parseType('List<String>?')),
      Field('v4', parseType('List<User>')),
      Field('v5', parseType('List<User?>')),
      Field('v6', parseType('List<User>?')),
      Field('v7', parseType('List<List<Book>>')),
      Field('v8', parseType('List<List<List<Book?>?>>')),
    ];
    final result = SerdesGenerator().generateClass('TestScheme', 'Test', schemeFields);
    final file = File('test_resources/generate_lists_fields.dart');
    expect(result, await file.readAsString());
  });
}
