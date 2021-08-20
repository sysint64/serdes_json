class Test {
  final TestScheme? $scheme = null;

  final User v1;
  final Book? v2;

  Test({
    required this.v1,
    this.v2,
  });

  Test.fromJson(Map<String, dynamic> json)
      : v1 = transformJsonValue<User, Map<String, dynamic>>(json, 'v1', (Map<String, dynamic> data) => User.fromJson(data)),
        v2 = transformJsonValueOrNull<Book, Map<String, dynamic>>(json, 'v2', (Map<String, dynamic> data) => Book.fromJson(data))
  {
  }

  static Test fromStringJson(String json) => Test.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['v1'] = v1.toJson();
    $result['v2'] = v2?.toJson();

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}
