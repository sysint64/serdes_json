import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:serdes_json/serdes_json.dart';

class Test {
  final List<int> v1;
  final List<int?> v2;
  final List<String>? v3;
  final List<User> v4;
  final List<User?> v5;
  final List<User>? v6;
  final List<List<Book>> v7;
  final List<List<List<Book?>?>> v8;

  Test({
    required this.v1,
    required this.v2,
    this.v3,
    required this.v4,
    required this.v5,
    this.v6,
    required this.v7,
    required this.v8,
  });

  Test.fromJson(Map<String, dynamic> json)
      : v1 = transformJsonListOfMap<int, dynamic>(json, 'v1', (dynamic it) => it as int),
        v2 = transformJsonListOfMap<int?, dynamic>(json, 'v2', (dynamic it) => it as int?),
        v3 =
            transformJsonListOfMapOrNull<String, dynamic>(json, 'v3', (dynamic it) => it as String),
        v4 = transformJsonListOfMap<User, dynamic>(
            json, 'v4', (dynamic it) => User.fromJson(it as Map<String, dynamic>)),
        v5 = transformJsonListOfMap<User?, dynamic>(json, 'v5',
            (dynamic it) => it == null ? null : User.fromJson(it as Map<String, dynamic>)),
        v6 = transformJsonListOfMapOrNull<User, dynamic>(
            json, 'v6', (dynamic it) => User.fromJson(it as Map<String, dynamic>)),
        v7 = transformJsonListOfMap<List<Book>, dynamic>(
            json,
            'v7',
            (dynamic it) => (it as Iterable<dynamic>)
                .map((dynamic it) => Book.fromJson(it as Map<String, dynamic>))
                .toList()),
        v8 = transformJsonListOfMap<List<List<Book?>?>, dynamic>(
            json,
            'v8',
            (dynamic it) => (it as Iterable<dynamic>)
                .map((dynamic it) => it == null
                    ? null
                    : (it as Iterable<dynamic>)
                        .map((dynamic it) => it == null
                            ? null
                            : it == null
                                ? null
                                : Book.fromJson(it as Map<String, dynamic>))
                        .toList())
                .toList());

  static Test fromStringJson(String json) =>
      Test.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['v1'] = v1.map((int it) => it).toList();
    $result['v2'] = v2.map((int? it) => it).toList();
    $result['v3'] = v3?.map((String it) => it).toList();
    $result['v4'] = v4.map((User it) => it.toJson()).toList();
    $result['v5'] = v5.map((User? it) => it?.toJson()).toList();
    $result['v6'] = v6?.map((User it) => it.toJson()).toList();
    $result['v7'] = v7.map((List<Book> it) => it.map((Book it) => it.toJson()).toList()).toList();
    $result['v8'] = v8
        .map((List<List<Book?>?> it) =>
            it.map((List<Book?>? it) => it?.map((Book? it) => it?.toJson()).toList()).toList())
        .toList();

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}

class User {
  final String name;
  final int age;

  User({
    required this.name,
    required this.age,
  });

  User.fromJson(Map<String, dynamic> json)
      : name = getJsonValue<String>(json, 'name'),
        age = getJsonValue<int>(json, 'age');

  static User fromStringJson(String json) =>
      User.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['name'] = name;
    $result['age'] = age;

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}

class Book {
  final String name;
  final int timestamp;

  Book({
    required this.name,
    required this.timestamp,
  });

  Book.fromJson(Map<String, dynamic> json)
      : name = getJsonValue<String>(json, 'name'),
        timestamp = getJsonValue<int>(json, 'timestamp');

  static Book fromStringJson(String json) =>
      Book.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['name'] = name;
    $result['timestamp'] = timestamp;

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}

void main() {
  test('lists 1', () async {
    final file = File('test_resources/lists.json');
    final json = await file.readAsString();
    final normJson = jsonEncode(jsonDecode(json));
    expect(Test.fromStringJson(json).toStringJson(), normJson);
  });

  test('lists 2', () async {
    final file = File('test_resources/lists2.json');
    final json = await file.readAsString();
    final normJson = jsonEncode(jsonDecode(json));
    expect(Test.fromStringJson(json).toStringJson(), normJson);
  });
}
