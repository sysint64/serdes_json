class TestMap {
  final TestMapScheme? $scheme = null;

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
      : v1 = getJsonValue<Map<String, dynamic>>(json, 'v1').map<String, int>((String key, dynamic value) => MapEntry<String, int>(key, value as int)),
        v2 = getJsonValue<Map<String, dynamic>>(json, 'v2').map<String, int?>((String key, dynamic value) => MapEntry<String, int?>(key, value as int?)),
        v3 = getJsonValueOrNull<Map<String, dynamic>>(json, 'v3')?.map<String, String>((String key, dynamic value) => MapEntry<String, String>(key, value as String)),
        v4 = getJsonValue<Map<String, dynamic>>(json, 'v4').map<String, User>((String key, dynamic value) => MapEntry<String, User>(key, User.fromJson(value as Map<String, dynamic>))),
        v5 = getJsonValue<Map<String, dynamic>>(json, 'v5').map<String, User?>((String key, dynamic value) => MapEntry<String, User?>(key, value == null ? null : User.fromJson(value as Map<String, dynamic>))),
        v6 = getJsonValueOrNull<Map<String, dynamic>>(json, 'v6')?.map<String, User>((String key, dynamic value) => MapEntry<String, User>(key, User.fromJson(value as Map<String, dynamic>))),
        v7 = getJsonValue<Map<String, dynamic>>(json, 'v7').map<String, Map<String, Book>>((String key, dynamic value) => MapEntry<String, Map<String, Book>>(key, (value as Map<String, dynamic>).map<String, Book>((String key, dynamic value) => MapEntry<String, Book>(key, Book.fromJson(value as Map<String, dynamic>))))),
        v8 = getJsonValue<Map<String, dynamic>>(json, 'v8').map<String, Map<String, Map<String, Book?>?>>((String key, dynamic value) => MapEntry<String, Map<String, Map<String, Book?>?>>(key, (value as Map<String, dynamic>).map<String, Map<String, Book?>?>((String key, dynamic value) => value == null ? MapEntry<String, Map<String, Book?>?>(key, null) : MapEntry<String, Map<String, Book?>?>(key, (value as Map<String, dynamic>).map<String, Book?>((String key, dynamic value) => value == null ? MapEntry<String, Book?>(key, null) : MapEntry<String, Book?>(key, value == null ? null : Book.fromJson(value as Map<String, dynamic>))))))),
        v9 = getJsonValue<Map<String, dynamic>>(json, 'v9').map<String, dynamic>((String key, dynamic value) => MapEntry<String, dynamic>(key, value)),
        v10 = getJsonValueOrNull<Map<String, dynamic>>(json, 'v10')?.map<String, String>((String key, dynamic value) => MapEntry<String, String>(key, value as String)),
        v11 = getJsonValueOrNull<Map<String, dynamic>>(json, 'v11')?.map<String, User>((String key, dynamic value) => MapEntry<String, User>(key, User.fromJson(value as Map<String, dynamic>))),
        v12 = getJsonValueOrNull<Map<String, dynamic>>(json, 'v12')?.map<String, dynamic>((String key, dynamic value) => MapEntry<String, dynamic>(key, value)),
        v13 = getJsonValueOrNull<Map<String, dynamic>>(json, 'v13')?.map<String, dynamic>((String key, dynamic value) => MapEntry<String, dynamic>(key, value))
  {
  }

  static TestMap fromStringJson(String json) => TestMap.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['v1'] = v1.map<String, dynamic>((String key, int value) => MapEntry<String, dynamic>(key, value));
    $result['v2'] = v2.map<String, dynamic>((String key, int? value) => MapEntry<String, dynamic>(key, value));
    $result['v3'] = v3?.map<String, dynamic>((String key, String value) => MapEntry<String, dynamic>(key, value));
    $result['v4'] = v4.map<String, dynamic>((String key, User value) => MapEntry<String, dynamic>(key, value.toJson()));
    $result['v5'] = v5.map<String, dynamic>((String key, User? value) => MapEntry<String, dynamic>(key, value?.toJson()));
    $result['v6'] = v6?.map<String, dynamic>((String key, User value) => MapEntry<String, dynamic>(key, value.toJson()));
    $result['v7'] = v7.map<String, dynamic>((String key, Map<String, Book> value) => MapEntry<String, dynamic>(key, value.map<String, dynamic>((String key, Book value) => MapEntry<String, dynamic>(key, value.toJson()))));
    $result['v8'] = v8.map<String, dynamic>((String key, Map<String, Map<String, Book?>?> value) => MapEntry<String, dynamic>(key, value.map<String, dynamic>((String key, Map<String, Book?>? value) => MapEntry<String, dynamic>(key, value?.map<String, dynamic>((String key, Book? value) => MapEntry<String, dynamic>(key, value?.toJson()))))));
    $result['v9'] = v9;
    $result['v10'] = v10?.map<String, dynamic>((String key, String value) => MapEntry<String, dynamic>(key, value));
    $result['v11'] = v11?.map<String, dynamic>((String key, User value) => MapEntry<String, dynamic>(key, value.toJson()));
    $result['v12'] = v12;
    $result['v13'] = v13;

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}
