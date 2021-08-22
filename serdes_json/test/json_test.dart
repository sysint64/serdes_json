import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:serdes_json/serdes_json.dart';

// Generated from:
// @SerdesJson(convertToSnakeCase: true)
// class TestListScheme {
//   late List<int> v1;
//   late List<int?> v2;
//   late List<String>? v3;
//   late List<UserScheme> v4;
//   late List<UserScheme?> v5;
//   late List<UserScheme>? v6;
//   late List<List<BookScheme>> v7;
//   late List<List<List<BookScheme?>?>> v8;
//   late List<dynamic> v9;
//   late List<String>? v10;
//   late List<UserScheme>? v11;
//   late List<dynamic>? v12;
//   late List<dynamic>? v13;
// }
class TestList {
  final List<int> v1;
  final List<int?> v2;
  final List<String>? v3;
  final List<User> v4;
  final List<User?> v5;
  final List<User>? v6;
  final List<List<Book>> v7;
  final List<List<List<Book?>?>> v8;
  final List<dynamic> v9;
  final List<String>? v10;
  final List<User>? v11;
  final List<dynamic>? v12;
  final List<dynamic>? v13;

  TestList({
    required this.v1,
    required this.v2,
    this.v3,
    required this.v4,
    required this.v5,
    this.v6,
    required this.v7,
    required this.v8,
    required this.v9,
    this.v10,
    this.v11,
    this.v12,
    this.v13,
  });

  TestList.fromJson(Map<String, dynamic> json)
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
                .toList()),
        v9 = getJsonValue<List<dynamic>>(json, 'v9'),
        v10 = transformJsonListOfMapOrNull<String, dynamic>(
            json, 'v10', (dynamic it) => it as String),
        v11 = transformJsonListOfMapOrNull<User, dynamic>(
            json, 'v11', (dynamic it) => User.fromJson(it as Map<String, dynamic>)),
        v12 = getJsonValueOrNull<List<dynamic>>(json, 'v12'),
        v13 = getJsonValueOrNull<List<dynamic>>(json, 'v13') {}

  static TestList fromStringJson(String json) =>
      TestList.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['v1'] = v1.map<dynamic>((int it) => it).toList();
    $result['v2'] = v2.map<dynamic>((int? it) => it).toList();
    $result['v3'] = v3?.map<dynamic>((String it) => it).toList();
    $result['v4'] = v4.map<dynamic>((User it) => it.toJson()).toList();
    $result['v5'] = v5.map<dynamic>((User? it) => it?.toJson()).toList();
    $result['v6'] = v6?.map<dynamic>((User it) => it.toJson()).toList();
    $result['v7'] = v7
        .map<dynamic>((List<Book> it) => it.map<dynamic>((Book it) => it.toJson()).toList())
        .toList();
    $result['v8'] = v8
        .map<dynamic>((List<List<Book?>?> it) => it
            .map<dynamic>(
                (List<Book?>? it) => it?.map<dynamic>((Book? it) => it?.toJson()).toList())
            .toList())
        .toList();
    $result['v9'] = v9;
    $result['v10'] = v10?.map<dynamic>((String it) => it).toList();
    $result['v11'] = v11?.map<dynamic>((User it) => it.toJson()).toList();
    $result['v12'] = v12;
    $result['v13'] = v13;

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}

// Generated from:
// @SerdesJson(convertToSnakeCase: true)
// class TestMapScheme {
//   late Map<String, int> v1;
//   late Map<String, int?> v2;
//   late Map<String, String>? v3;
//   late Map<String, UserScheme> v4;
//   late Map<String, UserScheme?> v5;
//   late Map<String, UserScheme>? v6;
//   late Map<String, Map<String, BookScheme>> v7;
//   late Map<String, Map<String, Map<String, BookScheme?>?>> v8;
//   late Map<String, dynamic> v9;
//   late Map<String, String>? v10;
//   late Map<String, UserScheme>? v11;
//   late Map<String, dynamic>? v12;
//   late Map<String, dynamic>? v13;
// }
class TestMap {
  final Map<String, int> v1;
  final Map<String, int?> v2;
  final Map<String, String>? v3;
  final Map<String, User> v4;
  final Map<String, User?> v5;
  final Map<String, User>? v6;
  final Map<String, Map<String, Book>> v7;
  final Map<String, Map<String, Map<String, Book?>?>> v8;
  final Map<String, dynamic> v9;
  final Map<String, String>? v10;
  final Map<String, User>? v11;
  final Map<String, dynamic>? v12;
  final Map<String, dynamic>? v13;

  TestMap({
    required this.v1,
    required this.v2,
    this.v3,
    required this.v4,
    required this.v5,
    this.v6,
    required this.v7,
    required this.v8,
    required this.v9,
    this.v10,
    this.v11,
    this.v12,
    this.v13,
  });

  TestMap.fromJson(Map<String, dynamic> json)
      : v1 = getJsonValue<Map<String, dynamic>>(json, 'v1').map<String, int>(
            (String key, dynamic value) => MapEntry<String, int>(key, value as int)),
        v2 = getJsonValue<Map<String, dynamic>>(json, 'v2').map<String, int?>(
            (String key, dynamic value) => MapEntry<String, int?>(key, value as int?)),
        v3 = getJsonValueOrNull<Map<String, dynamic>>(json, 'v3')?.map<String, String>(
            (String key, dynamic value) => MapEntry<String, String>(key, value as String)),
        v4 = getJsonValue<Map<String, dynamic>>(json, 'v4').map<String, User>(
            (String key, dynamic value) =>
                MapEntry<String, User>(key, User.fromJson(value as Map<String, dynamic>))),
        v5 = getJsonValue<Map<String, dynamic>>(json, 'v5').map<String, User?>(
            (String key, dynamic value) => MapEntry<String, User?>(
                key, value == null ? null : User.fromJson(value as Map<String, dynamic>))),
        v6 = getJsonValueOrNull<Map<String, dynamic>>(json, 'v6')?.map<String, User>(
            (String key, dynamic value) =>
                MapEntry<String, User>(key, User.fromJson(value as Map<String, dynamic>))),
        v7 = getJsonValue<Map<String, dynamic>>(json, 'v7').map<String, Map<String, Book>>(
            (String key, dynamic value) => MapEntry<String, Map<String, Book>>(
                key,
                (value as Map<String, dynamic>).map<String, Book>((String key, dynamic value) =>
                    MapEntry<String, Book>(key, Book.fromJson(value as Map<String, dynamic>))))),
        v8 = getJsonValue<Map<String, dynamic>>(json, 'v8').map<String, Map<String, Map<String, Book?>?>>(
            (String key, dynamic value) => MapEntry<String, Map<String, Map<String, Book?>?>>(
                key,
                (value as Map<String, dynamic>).map<String, Map<String, Book?>?>(
                    (String key, dynamic value) => value == null
                        ? MapEntry<String, Map<String, Book?>?>(key, null)
                        : MapEntry<String, Map<String, Book?>?>(
                            key,
                            (value as Map<String, dynamic>)
                                .map<String, Book?>((String key, dynamic value) => value == null ? MapEntry<String, Book?>(key, null) : MapEntry<String, Book?>(key, value == null ? null : Book.fromJson(value as Map<String, dynamic>))))))),
        v9 = getJsonValue<Map<String, dynamic>>(json, 'v9').map<String, dynamic>(
            (String key, dynamic value) => MapEntry<String, dynamic>(key, value)),
        v10 = getJsonValueOrNull<Map<String, dynamic>>(json, 'v10')?.map<String, String>(
            (String key, dynamic value) => MapEntry<String, String>(key, value as String)),
        v11 = getJsonValueOrNull<Map<String, dynamic>>(json, 'v11')?.map<String, User>(
            (String key, dynamic value) =>
                MapEntry<String, User>(key, User.fromJson(value as Map<String, dynamic>))),
        v12 = getJsonValueOrNull<Map<String, dynamic>>(json, 'v12')?.map<String, dynamic>(
            (String key, dynamic value) => MapEntry<String, dynamic>(key, value)),
        v13 = getJsonValueOrNull<Map<String, dynamic>>(json, 'v13')?.map<String, dynamic>(
            (String key, dynamic value) => MapEntry<String, dynamic>(key, value)) {}

  static TestMap fromStringJson(String json) =>
      TestMap.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['v1'] =
        v1.map<String, dynamic>((String key, int value) => MapEntry<String, dynamic>(key, value));
    $result['v2'] =
        v2.map<String, dynamic>((String key, int? value) => MapEntry<String, dynamic>(key, value));
    $result['v3'] = v3
        ?.map<String, dynamic>((String key, String value) => MapEntry<String, dynamic>(key, value));
    $result['v4'] = v4.map<String, dynamic>(
        (String key, User value) => MapEntry<String, dynamic>(key, value.toJson()));
    $result['v5'] = v5.map<String, dynamic>(
        (String key, User? value) => MapEntry<String, dynamic>(key, value?.toJson()));
    $result['v6'] = v6?.map<String, dynamic>(
        (String key, User value) => MapEntry<String, dynamic>(key, value.toJson()));
    $result['v7'] = v7.map<String, dynamic>((String key, Map<String, Book> value) =>
        MapEntry<String, dynamic>(
            key,
            value.map<String, dynamic>(
                (String key, Book value) => MapEntry<String, dynamic>(key, value.toJson()))));
    $result['v8'] = v8.map<String, dynamic>((String key, Map<String, Map<String, Book?>?> value) =>
        MapEntry<String, dynamic>(
            key,
            value.map<String, dynamic>((String key, Map<String, Book?>? value) =>
                MapEntry<String, dynamic>(
                    key,
                    value?.map<String, dynamic>((String key, Book? value) =>
                        MapEntry<String, dynamic>(key, value?.toJson()))))));
    $result['v9'] = v9;
    $result['v10'] = v10
        ?.map<String, dynamic>((String key, String value) => MapEntry<String, dynamic>(key, value));
    $result['v11'] = v11?.map<String, dynamic>(
        (String key, User value) => MapEntry<String, dynamic>(key, value.toJson()));
    $result['v12'] = v12;
    $result['v13'] = v13;

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}

// Generated from:
// @SerdesJson(convertToSnakeCase: true)
// class UserScheme {
//   late String name;
//   late int age;
// }
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

// Generated from
// @SerdesJson(convertToSnakeCase: true)
// class BookScheme {
//   late String name;
//   late int timestamp;
// }
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
  test('lists', () async {
    final file = File('test_resources/lists.json');
    final json = await file.readAsString();
    final normJson = jsonEncode(jsonDecode(json));
    expect(TestList.fromStringJson(json).toStringJson(), normJson);
  });

  test('maps 1', () async {
    final file = File('test_resources/maps.json');
    final json = await file.readAsString();
    final normJson = jsonEncode(jsonDecode(json));
    expect(TestMap.fromStringJson(json).toStringJson(), normJson);
  });
}
