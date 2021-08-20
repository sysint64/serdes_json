import 'package:serdes_json_generator/helpers.dart';
import 'package:serdes_json_generator/models.dart';
import 'package:serdes_json_generator/tokenizer.dart';

class TokenStream {
  final List<Token> _tokens;
  int _seek = 0;

  TokenStream(this._tokens);

  Token head() => _seek >= _tokens.length ? const Token.eof() : _tokens[_seek];

  List<Token> tail() => _tokens.sublist(_seek);

  Token nextToken() {
    if (_seek >= _tokens.length) {
      return const Token.eof();
    }

    _seek += 1;
    return head();
  }

  bool get isEmpty => _seek >= _tokens.length;

  bool get isNotEmpty => !isEmpty;
}

class ParseError extends Error {
  final String message;

  ParseError([this.message = 'Parse error']);

  @override
  String toString() => '$ParseError: $message';
}

FieldType parseType(String type) {
  final tokens = tokenize(StringStream(type));
  final stream = TokenStream(tokens);

  if (stream.isEmpty) {
    throw ParseError('nothing to parse');
  }

  final parsedType = _parseType(stream);

  if (stream.isNotEmpty) {
    throw ParseError('expected EOF but get ${stream.head()}');
  }

  return parsedType;
}

FieldType _parseType(TokenStream stream) {
  if (stream.head().tokenType != TokenType.id) {
    throw ParseError('expected id but get ${stream.head()}');
  }

  final name = stream.head().data;

  if (isPrimitive(name)) {
    return _parsePrimitive(stream);
  } else {
    return _parseNonPrimitive(stream);
  }
}

FieldType _parsePrimitive(TokenStream stream) {
  final name = stream.head().data;
  stream.nextToken();

  bool optional = false;
  String sufix = '';

  if (stream.head().data == '?') {
    optional = true;
    sufix = '?';
    stream.nextToken();
  }

  return FieldType(
    name: name,
    displayName: '$name$sufix',
    isOptional: optional,
    isPrimitive: true,
  );
}

FieldType _parseNonPrimitive(TokenStream stream) {
  final name = removeSchemeSuffix(stream.head().data);
  stream.nextToken();

  if (stream.head().data == '<') {
    final generics = _parseGenerics(stream);
    final genericsDisplayName = generics.map((type) => type.displayName).join(', ');

    bool optional = false;
    String sufix = '';

    if (stream.head().data == '?') {
      optional = true;
      sufix = '?';
      stream.nextToken();
    }

    return FieldType(
      name: name,
      displayName: '$name<$genericsDisplayName>$sufix',
      isPrimitive: false,
      isOptional: optional,
      generics: generics,
    );
  } else {
    bool optional = false;
    String sufix = '';

    if (stream.head().data == '?') {
      optional = true;
      sufix = '?';
      stream.nextToken();
    }

    return FieldType(
      name: name,
      displayName: '$name$sufix',
      isPrimitive: false,
      isOptional: optional,
    );
  }
}

List<FieldType> _parseGenerics(TokenStream stream) {
  stream.nextToken();
  final generics = _parseList(stream);

  if (stream.head().data != '>') {
    throw ParseError('expected ">" but get ${stream.head()}');
  }

  stream.nextToken();
  return generics;
}

List<FieldType> _parseList(TokenStream stream) {
  String token = ',';
  final types = <FieldType>[];

  while (token == ',') {
    types.add(_parseType(stream));
    token = stream.head().data;

    if (token == ',') {
      stream.nextToken();
    }
  }

  return types;
}
