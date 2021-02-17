import 'package:equatable/equatable.dart';

enum TokenType {
  id,
  symbol,
  eof,
}

class Token extends Equatable {
  final TokenType tokenType;
  final String data;

  const Token({this.tokenType, this.data});

  const Token.eof()
      : tokenType = TokenType.eof,
        data = '';

  Token copyWith({
    TokenType tokenType,
    String data,
  }) {
    return Token(
      tokenType: tokenType ?? this.tokenType,
      data: data ?? this.data,
    );
  }

  @override
  List<Object> get props => [tokenType, data];

  @override
  String toString() {
    return 'Token(TokenType: $tokenType, name: $data)';
  }
}

class StringStream {
  int _seek = 0;
  final String _data;

  StringStream(this._data);

  String head() => _seek >= _data.length ? '' : _data[_seek];

  String tail() => _data.substring(_seek);

  String eatChar() {
    if (_seek >= _data.length) {
      return '';
    }

    _seek += 1;
    return head();
  }

  bool get isEmpty => _seek >= _data.length;

  bool get isNotEmpty => !isEmpty;
}

List<Token> tokenize(StringStream input) {
  assert(input != null);

  final res = <Token>[];

  while (input.isNotEmpty) {
    final char = input.head();

    if (char == ' ') {
      input.eatChar();
      continue;
    } else if (_isAlpha(char) || char == '_') {
      res.add(_lexId(input));
    } else {
      res.add(_lexSymbol(input));
    }
  }

  return res;
}

Token _lexId(StringStream input) {
  String id = input.head();
  String char = input.eatChar();

  while (_isAlpha(char) || _isNumeric(char) || char == '_') {
    // ignore: use_string_buffers
    id += char;
    char = input.eatChar();
  }

  return Token(
    tokenType: TokenType.id,
    data: id,
  );
}

Token _lexSymbol(StringStream input) {
  final char = input.head();
  input.eatChar();

  return Token(
    tokenType: TokenType.symbol,
    data: char,
  );
}

bool _isAlpha(String char) {
  if (char.isEmpty) {
    return false;
  }

  assert(char.length == 1);
  const alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  return alphabet.contains(char);
}

bool _isNumeric(String char) {
  final res = int.tryParse(char);
  return res != null;
}
