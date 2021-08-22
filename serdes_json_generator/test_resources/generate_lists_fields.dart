class TestList {
  final TestListScheme? $scheme = null;

  final List<int> v1;
  final List<int?> v2;
  final List<String>? v3;
  final List<User> v4;
  final List<User?> v5;
  final List<User>? v6;
  final List<List<Book>> v7;
  final List<List<List<Book?>?>> v8;
  final List<dynamic> v9;
  final List<String>? v10;
  final List<User>? v11;
  final List<dynamic>? v12;
  final List<dynamic>? v13;

  TestList({
    required this.v1,
    required this.v2,
    this.v3,
    required this.v4,
    required this.v5,
    this.v6,
    required this.v7,
    required this.v8,
    required this.v9,
    this.v10,
    this.v11,
    this.v12,
    this.v13,
  });

  TestList.fromJson(Map<String, dynamic> json)
      : v1 = transformJsonListOfMap<int, dynamic>(json, 'v1', (dynamic it) => it as int),
        v2 = transformJsonListOfMap<int?, dynamic>(json, 'v2', (dynamic it) => it as int?),
        v3 = transformJsonListOfMapOrNull<String, dynamic>(json, 'v3', (dynamic it) => it as String),
        v4 = transformJsonListOfMap<User, dynamic>(json, 'v4', (dynamic it) => User.fromJson(it as Map<String, dynamic>)),
        v5 = transformJsonListOfMap<User?, dynamic>(json, 'v5', (dynamic it) => it == null ? null : User.fromJson(it as Map<String, dynamic>)),
        v6 = transformJsonListOfMapOrNull<User, dynamic>(json, 'v6', (dynamic it) => User.fromJson(it as Map<String, dynamic>)),
        v7 = transformJsonListOfMap<List<Book>, dynamic>(json, 'v7', (dynamic it) => (it as Iterable<dynamic>).map((dynamic it) => Book.fromJson(it as Map<String, dynamic>)).toList()),
        v8 = transformJsonListOfMap<List<List<Book?>?>, dynamic>(json, 'v8', (dynamic it) => (it as Iterable<dynamic>).map((dynamic it) => it == null ? null : (it as Iterable<dynamic>).map((dynamic it) => it == null ? null : it == null ? null : Book.fromJson(it as Map<String, dynamic>)).toList()).toList()),
        v9 = getJsonValue<List<dynamic>>(json, 'v9'),
        v10 = transformJsonListOfMapOrNull<String, dynamic>(json, 'v10', (dynamic it) => it as String),
        v11 = transformJsonListOfMapOrNull<User, dynamic>(json, 'v11', (dynamic it) => User.fromJson(it as Map<String, dynamic>)),
        v12 = getJsonValueOrNull<List<dynamic>>(json, 'v12'),
        v13 = getJsonValueOrNull<List<dynamic>>(json, 'v13')
  {
  }

  static TestList fromStringJson(String json) => TestList.fromJson(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final $result = <String, dynamic>{};

    $result['v1'] = v1.map<dynamic>((int it) => it).toList();
    $result['v2'] = v2.map<dynamic>((int? it) => it).toList();
    $result['v3'] = v3?.map<dynamic>((String it) => it).toList();
    $result['v4'] = v4.map<dynamic>((User it) => it.toJson()).toList();
    $result['v5'] = v5.map<dynamic>((User? it) => it?.toJson()).toList();
    $result['v6'] = v6?.map<dynamic>((User it) => it.toJson()).toList();
    $result['v7'] = v7.map<dynamic>((List<Book> it) => it.map<dynamic>((Book it) => it.toJson()).toList()).toList();
    $result['v8'] = v8.map<dynamic>((List<List<Book?>?> it) => it.map<dynamic>((List<Book?>? it) => it?.map<dynamic>((Book? it) => it?.toJson()).toList()).toList()).toList();
    $result['v9'] = v9;
    $result['v10'] = v10?.map<dynamic>((String it) => it).toList();
    $result['v11'] = v11?.map<dynamic>((User it) => it.toJson()).toList();
    $result['v12'] = v12;
    $result['v13'] = v13;

    return $result;
  }

  String toStringJson() => jsonEncode(toJson());
}
