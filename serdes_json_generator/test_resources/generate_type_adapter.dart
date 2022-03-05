class Test {
  final _TestScheme? $scheme = null;

  final DateTime dateTime;
  final Article article;
  final List<NewsItem> news;
  final Article? nullableArticle;
  final List<NewsItem>? nullableNews;

  Test({
    required this.dateTime,
    required this.article,
    required this.news,
    this.nullableArticle,
    this.nullableNews,
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

  static Article? _$createTypeAdapter$nullableArticle(Map<String, dynamic> json) {
    final object = getJsonValueOrNull<Map<String, dynamic>>(json, 'nullableArticle')?.map<String, dynamic>((String key, dynamic value) => MapEntry<String, dynamic>(key, value));
    return object == null ? null : const ArticleTypeAdapter().fromJson(object);
  }

  static List<NewsItem>? _$createTypeAdapter$nullableNews(Map<String, dynamic> json) {
    final object = transformJsonListOfMapOrNull<Map<String, dynamic>, dynamic>(json, 'nullableNews', (dynamic it) => it as Map<String, dynamic>);
    return object == null ? null : const NewsListTypeAdapter().fromJson(object);
  }

  Test.fromJson(Map<String, dynamic> json)
      : dateTime = _$createTypeAdapter$dateTime(json),
        article = _$createTypeAdapter$article(json),
        news = _$createTypeAdapter$news(json),
        nullableArticle = _$createTypeAdapter$nullableArticle(json),
        nullableNews = _$createTypeAdapter$nullableNews(json)
  {
  }

  static Test fromStringJson(String json) => Test.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['dateTime'] = const MyDateTimeTypeAdapter().toJson(dateTime);
    $result['article'] = const ArticleTypeAdapter().toJson(article);
    $result['news'] = const NewsListTypeAdapter().toJson(news);
    $result['nullableArticle'] = nullableArticle == null ? null : const ArticleTypeAdapter().toJson(nullableArticle!);
    $result['nullableNews'] = nullableNews == null ? null : const NewsListTypeAdapter().toJson(nullableNews!);

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}
