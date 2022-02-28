part of serdes_json;

class SerdesJson {
  final bool convertToSnakeCase;
  final bool toJson;
  final bool fromJson;
  final bool toStringJson;
  final bool fromStringJson;
  final String endsWith;

  const SerdesJson({
    this.convertToSnakeCase = false,
    this.toJson = true,
    this.fromJson = true,
    this.toStringJson = true,
    this.fromStringJson = true,
    this.endsWith = 'Scheme',
  });
}

class SerdesJsonField {
  final String? name;
  final String? union;
  final List<SerdesJsonUnion>? unionValues;

  const SerdesJsonField({
    this.name,
    this.union,
    this.unionValues,
  });
}

class SerdesJsonEnumField {
  final dynamic value;

  const SerdesJsonEnumField({this.value});
}

class SerdesJsonUnion {
  final String value;
  final Type type;

  const SerdesJsonUnion(this.value, this.type);
}

abstract class SerdesJsonUnionContent {
  Map<String, dynamic> toJson();
}
