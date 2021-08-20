part of serdes_json;

T getJsonValue<T>(Map<String, dynamic> json, String key) {
  if (!json.containsKey(key)) {
    throw SchemeConsistencyException('key "$key" hasn\'t found');
  } else if (json[key] is! T) {
    if (T == double && json[key] is int) {
      return json[key].toDouble();
    } else {
      throw SchemeConsistencyException(
        'Wrong type by key "$key", expected: "$T" '
        'but has got: "${json[key].runtimeType}"',
      );
    }
  } else {
    return json[key] as T;
  }
}

T? getJsonValueOrNull<T>(
  Map<String, dynamic> json,
  String key,
) {
  if (json.containsKey(key) && json[key] != null) {
    return getJsonValue(json, key);
  } else {
    return null;
  }
}

T? transformJsonValueOrNull<T, R>(
  Map<String, dynamic> json,
  String key,
  T Function(R) transform,
) {
  if (json.containsKey(key) && json[key] != null) {
    return transform(getJsonValue(json, key));
  } else {
    return null;
  }
}

List<T> transformJsonListOfMap<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic>) transform,
) {
  final List<dynamic> list = getJsonValue(json, key);

  T mapper(it) {
    try {
      return transform(it as Map<String, dynamic>);
    } on Exception catch (e, _) {
      throw SchemeConsistencyException(
        'Failed to transform value "$it";\ncause: $e',
      );
    }
  }

  return list.isEmpty ? [] : list.map(mapper).toList();
}

List<T> transformJsonListOfString<T>(
  Map<String, dynamic> json,
  String key,
) {
  final List<dynamic> list = getJsonValue(json, key);

  String mapper(it) {
    try {
      return it as String;
    } on Exception catch (e) {
      throw SchemeConsistencyException(
        'Failed to transform value "$it";\ncause: $e',
      );
    }
  }

  return list.isEmpty ? [] : list.map(mapper).toList() as List<T>;
}

List<T>? transformJsonListOfMapOrNull<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic>) transform,
) {
  if (json.containsKey(key) && json[key] != null) {
    final List<dynamic> list = getJsonValue(json, key);

    T mapper(it) {
      try {
        return transform(it as Map<String, dynamic>);
      } on Exception catch (e) {
        throw SchemeConsistencyException(
          'Failed to transform value "$it";\ncause: $e',
        );
      }
    }

    return list.isEmpty ? [] : list.map(mapper).toList();
  } else {
    return null;
  }
}

List<T> transformJsonList<T>(
  List<dynamic> json,
  T Function(Map<String, dynamic>) transform,
) {
  T mapper(it) {
    try {
      return transform(it as Map<String, dynamic>);
    } on Exception catch (e) {
      throw SchemeConsistencyException(
        'Failed to transform value "$it";\ncause: $e',
      );
    }
  }

  return json.isEmpty ? [] : json.map(mapper).toList();
}

List<T> getJsonList<T>(
  Map<String, dynamic> json,
  String key,
) {
  final List<dynamic> list = getJsonValue(json, key);

  T mapper(it) {
    if (it is T) {
      return it;
    } else {
      throw SchemeConsistencyException(
        'Wrong type by key "$key", expected: "List<$T>" '
        'but has got element in list of type: "${it.runtimeType}"',
      );
    }
  }

  return list.isEmpty ? <T>[] : list.map(mapper).toList();
}

List<T>? getJsonListOrNull<T>(
  Map<String, dynamic> json,
  String key,
) {
  if (json.containsKey(key) && json[key] != null) {
    final List<dynamic> list = getJsonValue(json, key);

    T mapper(it) {
      if (it is T) {
        return it;
      } else {
        throw SchemeConsistencyException(
          'Wrong type by key "$key", expected: "List<$T>" '
          'but has got element in list of type: "${it.runtimeType}"',
        );
      }
    }

    return list.isEmpty ? <T>[] : list.map(mapper).toList();
  } else {
    return null;
  }
}

Map<String, T> getJsonMap<T>(Map<String, dynamic> json, String key) {
  final Map<String, dynamic> map = getJsonValue(json, key);

  MapEntry<String, T> mapper(String key, dynamic value) {
    if (value is T) {
      return MapEntry<String, T>(key, value);
    } else {
      throw SchemeConsistencyException(
        'Wrong type by key "$key", expected: "List<$T>" '
        'but has got element in list of type: "${value.runtimeType}"',
      );
    }
  }

  return map.isEmpty ? <String, T>{} : map.map(mapper);
}

Map<String, T>? getJsonMapOrNull<T>(Map<String, dynamic> json, String key) {
  if (json.containsKey(key) && json[key] != null) {
    final Map<String, dynamic> map = getJsonValue(json, key);

    MapEntry<String, T> mapper(String key, dynamic value) {
      if (value is T) {
        return MapEntry<String, T>(key, value);
      } else {
        throw SchemeConsistencyException(
          'Wrong type by key "$key", expected: "List<$T>" '
          'but has got element in list of type: "${value.runtimeType}"',
        );
      }
    }

    return map.isEmpty ? <String, T>{} : map.map(mapper);
  } else {
    return null;
  }
}
