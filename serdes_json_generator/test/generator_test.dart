import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:serdes_json_generator/models.dart';
import 'package:serdes_json_generator/parser.dart';
import 'package:serdes_json_generator/serdes_generator.dart';

void main() {
  test('genrate class - primitives', () async {
    final primitivesFields = <Field>[
      Field('v1', 'v1', parseType('int')),
      Field('v2', 'v2', parseType('int?')),
      Field('v3', 'v3', parseType('String')),
      Field('v4', 'v4', parseType('String?')),
    ];
    final result = SerdesGenerator().generateClass('TestScheme', 'Test', primitivesFields);
    final file = File('test_resources/generate_primitives_fields.dart');
    expect(result, await file.readAsString());
  });

  test('generate class - schemes', () async {
    final schemeFields = <Field>[
      Field('v1', 'v1', parseType('UserScheme')),
      Field('v2', 'v2', parseType('BookScheme?')),
    ];
    final result = SerdesGenerator().generateClass('TestScheme', 'Test', schemeFields);
    final file = File('test_resources/generate_schemes_fields.dart');
    expect(result, await file.readAsString());
  });

  test('generate class - privete schemes', () async {
    final schemeFields = <Field>[
      Field('v1', 'v1', parseType('_UserScheme')),
      Field('v2', 'v2', parseType('_BookScheme?')),
    ];
    final result = SerdesGenerator().generateClass('TestScheme', 'Test', schemeFields);
    final file = File('test_resources/generate_schemes_fields.dart');
    expect(result, await file.readAsString());
  });

  test('generate class - lists', () async {
    final schemeFields = <Field>[
      Field('v1', 'v1', parseType('List<int>')),
      Field('v2', 'v2', parseType('List<int?>')),
      Field('v3', 'v3', parseType('List<String>?')),
      Field('v4', 'v4', parseType('List<User>')),
      Field('v5', 'v5', parseType('List<User?>')),
      Field('v6', 'v6', parseType('List<User>?')),
      Field('v7', 'v7', parseType('List<List<Book>>')),
      Field('v8', 'v8', parseType('List<List<List<Book?>?>>')),
      Field('v9', 'v9', parseType('List<dynamic>')),
      Field('v10', 'v10', parseType('List<String>?')),
      Field('v11', 'v11', parseType('List<UserScheme>?')),
      Field('v12', 'v12', parseType('List<dynamic>?')),
      Field('v13', 'v13', parseType('List<dynamic>?')),
    ];
    final result = SerdesGenerator().generateClass('TestListScheme', 'TestList', schemeFields);
    final file = File('test_resources/generate_lists_fields.dart');
    expect(result, await file.readAsString());
  });

  test('generate class - lists with private schemes', () async {
    final schemeFields = <Field>[
      Field('v1', 'v1', parseType('List<int>')),
      Field('v2', 'v2', parseType('List<int?>')),
      Field('v3', 'v3', parseType('List<String>?')),
      Field('v4', 'v4', parseType('List<User>')),
      Field('v5', 'v5', parseType('List<User?>')),
      Field('v6', 'v6', parseType('List<User>?')),
      Field('v7', 'v7', parseType('List<List<_BookScheme>>')),
      Field('v8', 'v8', parseType('List<List<List<_BookScheme?>?>>')),
      Field('v9', 'v9', parseType('List<dynamic>')),
      Field('v10', 'v10', parseType('List<String>?')),
      Field('v11', 'v11', parseType('List<UserScheme>?')),
      Field('v12', 'v12', parseType('List<dynamic>?')),
      Field('v13', 'v13', parseType('List<dynamic>?')),
    ];
    final result = SerdesGenerator().generateClass('TestListScheme', 'TestList', schemeFields);
    final file = File('test_resources/generate_lists_fields.dart');
    expect(result, await file.readAsString());
  });

  test('generate class - maps', () async {
    final schemeFields = <Field>[
      Field('v1', 'v1', parseType('Map<String, int>')),
      Field('v2', 'v2', parseType('Map<String, int?>')),
      Field('v3', 'v3', parseType('Map<String, String>?')),
      Field('v4', 'v4', parseType('Map<String, User>')),
      Field('v5', 'v5', parseType('Map<String, User?>')),
      Field('v6', 'v6', parseType('Map<String, User>?')),
      Field('v7', 'v7', parseType('Map<String, Map<String, Book>>')),
      Field('v8', 'v8', parseType('Map<String, Map<String, Map<String, Book?>?>>')),
      Field('v9', 'v9', parseType('Map<String, dynamic>')),
      Field('v10', 'v10', parseType('Map<String, String>?')),
      Field('v11', 'v11', parseType('Map<String, UserScheme>?')),
      Field('v12', 'v12', parseType('Map<String, dynamic>?')),
      Field('v13', 'v13', parseType('Map<String, dynamic>?')),
    ];
    final result = SerdesGenerator().generateClass('TestMapScheme', 'TestMap', schemeFields);
    final file = File('test_resources/generate_maps_fields.dart');
    expect(result, await file.readAsString());
  });

  test('genrate class - rename', () async {
    final primitivesFields = <Field>[
      Field('count', 'count', parseType('int')),
      Field('isVisible', 'is_visible', parseType('bool')),
      Field('firstName', 'first_name', parseType('String')),
      Field('lastName', 'last_name', parseType('String?')),
    ];
    final result = SerdesGenerator().generateClass('TestScheme', 'Test', primitivesFields);
    final file = File('test_resources/generate_rename_fields.dart');
    expect(result, await file.readAsString());
  });

  test('genrate class - private scheme', () async {
    final primitivesFields = <Field>[
      Field('v1', 'v1', parseType('int')),
      Field('v2', 'v2', parseType('int?')),
      Field('v3', 'v3', parseType('String')),
      Field('v4', 'v4', parseType('String?')),
    ];
    final result = SerdesGenerator().generateClass('_TestScheme', '_Test', primitivesFields);
    final file = File('test_resources/generate_private_scheme.dart');
    expect(result, await file.readAsString());
  });

  test('genrate class - union', () async {
    final fields = <Field>[
      Field('type', 'type', parseType('String')),
      UnionField(
        'content',
        'content',
        parseType('UnionContent'),
        'type',
        [
          FieldUnionData('header', parseType('HeaderScheme')),
          FieldUnionData('footer', parseType('FooterScheme')),
        ],
      ),
    ];
    final result = SerdesGenerator().generateClass('_UnionScheme', '_Union', fields);
    final file = File('test_resources/generate_union_scheme.dart');
    expect(result, await file.readAsString());
  });
}
