# serdes_json

serdes_json - is a simple and clean serializer and deserializer.
To create serializable model just describe your model, add `Scheme` suffix to the end of class name,
and annotate with `@SerdesJson`. That's it!

## Examples

### Model with all required fields

```dart
@SerdesJson()
class NewsListScheme {
  List<NewsItemScheme> news;
}
```

```dart
@SerdesJson()
class NewsItemScheme {
  int id;
  String title;
  String description;
  int commentsCount;
}
```

### Snake case models

To convert all names to snake case, add `convertToSnakeCase: true` to the annotation:

```dart
@SerdesJson(convertToSnakeCase: true)
class NewsItemScheme {
  int id;
  String title;
  String description;
  int commentsCount;
}
```

### Optional

By default all fields are required, and if there will not be a field, then parser will throw the `SchemeConsistencyException`.
To describe optional fields use [https://pub.dev/packages/optional](optional) library:

```dart
@SerdesJson()
class PayloadScheme {
  Optional<Map<dynamic, dynamic>> result;
  Optional<ErrorScheme> error;
}
```


### To json

```dart
final news = NewsItem(
  id: 1,
  title: 'Some new',
  description: 'Description',
  commentsCount: 12',
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
