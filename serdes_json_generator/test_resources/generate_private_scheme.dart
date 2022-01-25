class Test {
  final _TestScheme? $scheme = null;

  final int v1;
  final int? v2;
  final String v3;
  final String? v4;

  Test({
    required this.v1,
    this.v2,
    required this.v3,
    this.v4,
  });

  Test.fromJson(Map<String, dynamic> json)
      : v1 = getJsonValue<int>(json, 'v1'),
        v2 = getJsonValueOrNull<int>(json, 'v2'),
        v3 = getJsonValue<String>(json, 'v3'),
        v4 = getJsonValueOrNull<String>(json, 'v4')
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
