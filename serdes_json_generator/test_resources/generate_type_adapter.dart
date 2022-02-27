class Test {
  final _TestScheme? $scheme = null;

  final DateTime dateTime;
  final Article article;
  final List<NewsItem> news;

  Test({
    required this.dateTime,
    required this.article,
    required this.news,
  });

  static DateTime _$createTypeAdapter$dateTime(Map<String, dynamic> json) {
    final object = getJsonValue<String>(json, 'dateTime');
    return const MyDateTimeTypeAdapter().fromJson(object);
  }

  static Article _$createTypeAdapter$article(Map<String, dynamic> json) {
    final object = getJsonValue<Map<String, dynamic>>(json, 'article').map<String, dynamic>((String key, dynamic value) => MapEntry<String, dynamic>(key, value));
    return const ArticleTypeAdapter().fromJson(object);
  }

  static List<NewsItem> _$createTypeAdapter$news(Map<String, dynamic> json) {
    final object = transformJsonListOfMap<Map<String, dynamic>, dynamic>(json, 'news', (dynamic it) => it as Map<String, dynamic>);
    return const NewsListTypeAdapter().fromJson(object);
  }

  Test.fromJson(Map<String, dynamic> json)
      : dateTime = _$createTypeAdapter$dateTime(json),
        article = _$createTypeAdapter$article(json),
        news = _$createTypeAdapter$news(json)
  {
  }

  static Test fromStringJson(String json) => Test.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['dateTime'] = const MyDateTimeTypeAdapter().toJson(dateTime);
    $result['article'] = const ArticleTypeAdapter().toJson(article);
    $result['news'] = const NewsListTypeAdapter().toJson(news);

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}
