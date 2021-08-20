# serdes_json

serdes_json - is a simple and clean serializer and deserializer.
To create serializable model just describe your model, add `Scheme` suffix to the end of class name,
and annotate with `@SerdesJson`. That's it!

## Examples

### Model with all required fields

```dart
import 'package:serdes_json/serdes_json.dart'

@SerdesJson()
class NewsListScheme {
  late List<NewsItemScheme> news;
}
```

```dart
@SerdesJson()
class NewsItemScheme {
  late int id;
  late String title;
  late String description;
  late int commentsCount;
}
```

### Snake case models

To convert all names to snake case, add `convertToSnakeCase: true` to the annotation:

```dart
@SerdesJson(convertToSnakeCase: true)
class NewsItemScheme {
  late int id;
  late String title;
  late String description;
  late int commentsCount;
}
```

### Optional

By default all fields are required, and if there will not be a field, then parser will throw the `SchemeConsistencyException`.
To describe optional fields:

```dart
@SerdesJson()
class PayloadScheme {
  late Map<dynamic, dynamic>? result;
  late ErrorScheme? error;
}
```

### Enums

TBD

### To json

```dart
final news = NewsItem(
  id: 1,
  title: 'Some new',
  description: 'Description',
  commentsCount: 12,
);

final json = news.toJson();
final stringJson = news.toStringJson();
```

### From json

```dart
final json = _client.getJsonBody(response);
final jsonString = _client.getStringJsonBody(response);

final news = NewsItem.fromJson(json);
final news = NewsItem.fromStringJson(jsonString);
```
