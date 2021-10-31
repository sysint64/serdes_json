class Test {
  final TestScheme? $scheme = null;

  final int count;
  final bool isVisible;
  final String firstName;
  final String? lastName;

  Test({
    required this.count,
    required this.isVisible,
    required this.firstName,
    this.lastName,
  });

  Test.fromJson(Map<String, dynamic> json)
      : count = getJsonValue<int>(json, 'count'),
        isVisible = getJsonValue<bool>(json, 'is_visible'),
        firstName = getJsonValue<String>(json, 'first_name'),
        lastName = getJsonValueOrNull<String>(json, 'last_name')
  {
  }

  static Test fromStringJson(String json) => Test.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['count'] = count;
    $result['is_visible'] = isVisible;
    $result['first_name'] = firstName;
    $result['last_name'] = lastName;

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}
