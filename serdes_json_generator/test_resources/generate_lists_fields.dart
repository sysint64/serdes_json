class Test {
  final TestScheme? $scheme = null;

  final List<int> v1;
  final List<int?> v2;
  final List<String>? v3;
  final List<User> v4;
  final List<User?> v5;
  final List<User>? v6;
  final List<List<Book>> v7;
  final List<List<Book>> v8;

  Test({
    required this.v1,
    this.v2,
    required this.v3,
    this.v4,
  });

  Test.fromJson(Map<String, dynamic> json)
      : v1 = getJsonValue(json, 'v1'),
        v2 = getJsonValueOrNull(json, 'v2'),
        v3 = getJsonValue(json, 'v3'),
        v4 = getJsonValueOrNull(json, 'v4')
  {
  }

  static Test fromStringJson(String json) => Test.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['v1'] = v1;
    $result['v2'] = v2;
    $result['v3'] = v3;
    $result['v4'] = v4;

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}
