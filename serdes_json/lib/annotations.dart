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
