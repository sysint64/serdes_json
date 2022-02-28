abstract class _$SerdesJson_TestEnumTypeAdapter {
  static TestEnum fromJson(String fieldName, dynamic json) {
    final value = fromJsonNullable(fieldName, json);
    if (value == null) {
      throw SchemeConsistencyException('field: "$fieldName" can\'t be null');
    } else {
      return value;
    }
  }

  static TestEnum? fromJsonNullable(String fieldName, dynamic json) {
    if (json == null) {
      return null;
    }
    if (json == 'internal_error') {
      return TestEnum.internalError;
    } else if (json == 400) {
      return TestEnum.badRequest;
    } else {
      throw SchemeConsistencyException('Unsupported "TestEnum" value: $json for field "$fieldName". Supported values: \'internal_error\',400');
    }
  }

  static dynamic toJson(String fieldName, TestEnum object) {
    final value = toJsonNullable(object);
    if (value == null) {
      throw SchemeConsistencyException('field: "$fieldName" can\'t be null');
    } else {
      return value;
    }
  }

  static dynamic toJsonNullable(TestEnum? object) {
    if (object == null) {
      return null;
    }
    switch (object) {
      case TestEnum.internalError:
        return 'internal_error';
      case TestEnum.badRequest:
        return 400;
    }
  }
}
