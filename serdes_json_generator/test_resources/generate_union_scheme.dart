class Union {
  final _UnionScheme? $scheme = null;

  final String type;
  final UnionContent content;

  Union({
    required this.type,
    required this.content,
  });

  static UnionContent _$createUnion$content(Map<String, dynamic> json) {
    final union = getJsonValue<String>(json, 'type').toString();
    final content = getJsonValue<Map<String, dynamic>>(json, 'content').map<String, dynamic>((String key, dynamic value) => MapEntry<String, dynamic>(key, value));

    if (union == 'header') {
      return Header.fromJson(content);
    } else if (union == 'footer') {
      return Footer.fromJson(content);
    } else {
      throw SchemeConsistencyException('Unsupported "type" value: $union. Supported values: header,footer');
    }
  }

  Union.fromJson(Map<String, dynamic> json)
      : type = getJsonValue<String>(json, 'type'),
        content = _$createUnion$content(json)
  {
  }

  static Union fromStringJson(String json) => Union.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['type'] = type;
    $result['content'] = content.toJson();

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}
