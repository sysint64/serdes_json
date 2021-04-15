import 'package:optional/optional.dart';
import 'package:flutter/foundation.dart';
import 'exceptions.dart';

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

Optional<T> getJsonValueOrEmpty<T>(
  Map<String, dynamic> json,
  String key,
) {
  if (json.containsKey(key) && json[key] != null) {
    return Optional.of(getJsonValue(json, key));
  } else {
    return const Optional.empty();
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

Optional<T> transformJsonValueOrEmpty<T, R>(
  Map<String, dynamic> json,
  String key,
  T Function(R) transform,
) {
  if (json.containsKey(key) && json[key] != null) {
    return Optional.of(transform(getJsonValue(json, key)));
  } else {
    return const Optional.empty();
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
    } on Exception catch (e, stacktrace) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
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

Optional<List<T>> transformJsonListOfMapOrEmpty<T>(
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

    return Optional.of(list.isEmpty ? [] : list.map(mapper).toList());
  } else {
    return const Optional.empty();
  }
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

Optional<List<T>> getJsonListOrEmpty<T>(
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

    return Optional.of(list.isEmpty ? <T>[] : list.map(mapper).toList());
  } else {
    return const Optional.empty();
  }
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
