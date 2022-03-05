class Test {
  final TestScheme? $scheme = null;

  final TestEnum enumValue;
  final TestEnum? nullableEnumValue;

  Test({
    required this.enumValue,
    this.nullableEnumValue,
  });

  Test.fromJson(Map<String, dynamic> json)
      : enumValue = $SerdesJson_TestEnumTypeAdapter.fromJson('enum_value', getJsonValue<dynamic>(json, 'enum_value')),
        nullableEnumValue = $SerdesJson_TestEnumTypeAdapter.fromJsonNullable('nullable_enum_value', getJsonValue<dynamic>(json, 'nullable_enum_value'))
  {
  }

  static Test fromStringJson(String json) => Test.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['enum_value'] = $SerdesJson_TestEnumTypeAdapter.toJson('enum_value', enumValue);
    $result['nullable_enum_value'] = $SerdesJson_TestEnumTypeAdapter.toJsonNullable(nullableEnumValue);

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}
