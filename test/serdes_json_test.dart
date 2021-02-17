import 'package:flutter_test/flutter_test.dart';
import 'package:serdes_json/models.dart';
import 'package:serdes_json/tokenizer.dart';
import 'package:serdes_json/parser.dart';

void main() {
  test('parse primitive', () async {
    expect(FieldType(isPrimitive: true, name: 'int', displayName: 'int'), parseType('int'));
    expect(FieldType(isPrimitive: true, name: 'String', displayName: 'String'), parseType('String'));
    expect(FieldType(isPrimitive: true, name: 'bool', displayName: 'bool'), parseType('bool'));
    expect(FieldType(isPrimitive: true, name: 'num', displayName: 'num'), parseType('num'));
    expect(FieldType(isPrimitive: true, name: 'num', displayName: 'num'), parseType(' num'));
  });

  test('parse non primitive', () async {
    expect(FieldType(isPrimitive: false, name: 'Box', displayName: 'Box'), parseType('Box'));
  });

  test('parse generic', () async {
    expect(
      parseType('Box<int>'),
      FieldType(
        isPrimitive: false,
        name: 'Box',
        displayName: 'Box<int>',
        generics: [
          FieldType(
            isPrimitive: true,
            name: 'int',
            displayName: 'int',
          )
        ],
      ),
    );
  });

  test('parse generic 2', () async {
    expect(
      parseType('Box<Model>'),
      FieldType(
        isPrimitive: false,
        name: 'Box',
        displayName: 'Box<Model>',
        generics: [
          FieldType(
            isPrimitive: false,
            name: 'Model',
            displayName: 'Model',
          )
        ],
      ),
    );
  });

  test('parse nested generic', () async {
    expect(
      parseType('Box<Optional<int>>'),
      FieldType(
        isPrimitive: false,
        name: 'Box',
        displayName: 'Box<Optional<int>>',
        generics: [
          FieldType(
            isPrimitive: false,
            name: 'Optional',
            displayName: 'Optional<int>',
            generics: [
              FieldType(
                isPrimitive: true,
                name: 'int',
                displayName: 'int',
              ),
            ],
          ),
        ],
      ),
    );
  });

  test('parse multiple generic', () async {
    expect(
      parseType('Map<String, int>'),
      FieldType(
        isPrimitive: false,
        name: 'Map',
        displayName: 'Map<String, int>',
        generics: [
          FieldType(
            isPrimitive: true,
            name: 'String',
            displayName: 'String',
          ),
          FieldType(
            isPrimitive: true,
            name: 'int',
            displayName: 'int',
          ),
        ],
      ),
    );
  });

  test('parse multiple generic', () async {
    expect(
      parseType('CustomMap<String, int, bool>'),
      FieldType(
        isPrimitive: false,
        name: 'CustomMap',
        displayName: 'CustomMap<String, int, bool>',
        generics: [
          FieldType(
            isPrimitive: true,
            name: 'String',
            displayName: 'String',
          ),
          FieldType(
            isPrimitive: true,
            name: 'int',
            displayName: 'int',
          ),
          FieldType(
            isPrimitive: true,
            name: 'bool',
            displayName: 'bool',
          ),
        ],
      ),
    );
  });

  test('parse multiple nested generic', () async {
    expect(
      parseType('Map<Optional<String>, int>'),
      FieldType(
        isPrimitive: false,
        name: 'Map',
        displayName: 'Map<Optional<String>, int>',
        generics: [
          FieldType(
            name: 'Optional',
            displayName: 'Optional<String>',
            isPrimitive: false,
            generics: [
              FieldType(
                isPrimitive: true,
                name: 'String',
                displayName: 'String',
              ),
            ],
          ),
          FieldType(
            isPrimitive: true,
            name: 'int',
            displayName: 'int',
          ),
        ],
      ),
    );
  });

  test('parse multiple nested generic 2', () async {
    expect(
      parseType('Optional<Map<String, int>>'),
      FieldType(
        isPrimitive: false,
        name: 'Optional',
        displayName: 'Optional<Map<String, int>>',
        generics: [
          FieldType(
            name: 'Map',
            displayName: 'Map<String, int>',
            isPrimitive: false,
            generics: [
              FieldType(
                isPrimitive: true,
                name: 'String',
                displayName: 'String',
              ),
              FieldType(
                isPrimitive: true,
                name: 'int',
                displayName: 'int',
              ),
            ],
          ),
        ],
      ),
    );
  });

  test('parse multiple nested generic 3', () async {
    expect(
      parseType('Optional<Map<String, Optional<int>>>'),
      FieldType(
        isPrimitive: false,
        name: 'Optional',
        displayName: 'Optional<Map<String, Optional<int>>>',
        generics: [
          FieldType(
            name: 'Map',
            displayName: 'Map<String, Optional<int>>',
            isPrimitive: false,
            generics: [
              FieldType(
                isPrimitive: true,
                name: 'String',
                displayName: 'String',
              ),
              FieldType(
                isPrimitive: false,
                name: 'Optional',
                displayName: 'Optional<int>',
                generics: [
                  FieldType(
                    isPrimitive: true,
                    name: 'int',
                    displayName: 'int',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  });

  test('remove Scheme', () async {
    expect(
      parseType('TestScheme'),
      FieldType(
        isPrimitive: false,
        name: 'Test',
        displayName: 'Test',
      ),
    );
  });

  test('remove Scheme', () async {
    expect(
      parseType('List<TestScheme>'),
      FieldType(
        isPrimitive: false,
        name: 'List',
        displayName: 'List<Test>',
        generics: [
          FieldType(
            name: 'Test',
            displayName: 'Test',
            isPrimitive: false,
          ),
        ],
      ),
    );
  });

  test('remove Scheme', () async {
    expect(
      parseType('List<ListScheme<TestScheme>>'),
      FieldType(
        isPrimitive: false,
        name: 'List',
        displayName: 'List<List<Test>>',
        generics: [
          FieldType(
            name: 'List',
            displayName: 'List<Test>',
            isPrimitive: false,
            generics: [
              FieldType(
                name: 'Test',
                displayName: 'Test',
                isPrimitive: false,
              ),
            ],
          ),
        ],
      ),
    );
  });

  test('tokenize primitive int', () async {
    expect(
      tokenize(StringStream('int')),
      [
        Token(tokenType: TokenType.id, data: 'int'),
      ],
    );
  });

  test('tokenize primitive bool', () async {
    expect(
      tokenize(StringStream('bool')),
      [
        Token(tokenType: TokenType.id, data: 'bool'),
      ],
    );
  });

  test('tokenize primitive String', () async {
    expect(
      tokenize(StringStream('String')),
      [
        Token(tokenType: TokenType.id, data: 'String'),
      ],
    );
  });

  test('tokenize compound Map<String, int>', () async {
    expect(
      tokenize(StringStream('Map<String, int>')),
      [
        Token(tokenType: TokenType.id, data: 'Map'),
        Token(tokenType: TokenType.symbol, data: '<'),
        Token(tokenType: TokenType.id, data: 'String'),
        Token(tokenType: TokenType.symbol, data: ','),
        Token(tokenType: TokenType.id, data: 'int'),
        Token(tokenType: TokenType.symbol, data: '>'),
      ],
    );
  });

  test('tokenize compound List<bool>', () async {
    expect(
      tokenize(StringStream('List<bool>')),
      [
        Token(tokenType: TokenType.id, data: 'List'),
        Token(tokenType: TokenType.symbol, data: '<'),
        Token(tokenType: TokenType.id, data: 'bool'),
        Token(tokenType: TokenType.symbol, data: '>'),
      ],
    );
  });

  test('tokenize compound List<App_Item>', () async {
    expect(
      tokenize(StringStream('List<App_Item>')),
      [
        Token(tokenType: TokenType.id, data: 'List'),
        Token(tokenType: TokenType.symbol, data: '<'),
        Token(tokenType: TokenType.id, data: 'App_Item'),
        Token(tokenType: TokenType.symbol, data: '>'),
      ],
    );
  });

  test('tokenize compound Map<App_Item, _Item>', () async {
    expect(
      tokenize(StringStream('Map<App_Item, _Item>')),
      [
        Token(tokenType: TokenType.id, data: 'Map'),
        Token(tokenType: TokenType.symbol, data: '<'),
        Token(tokenType: TokenType.id, data: 'App_Item'),
        Token(tokenType: TokenType.symbol, data: ','),
        Token(tokenType: TokenType.id, data: '_Item'),
        Token(tokenType: TokenType.symbol, data: '>'),
      ],
    );
  });

  test('tokenize compound with spaces 1', () async {
    expect(
      tokenize(StringStream('Optional<  Map < App_Item21, _Item015   >  > ')),
      [
        Token(tokenType: TokenType.id, data: 'Optional'),
        Token(tokenType: TokenType.symbol, data: '<'),
        Token(tokenType: TokenType.id, data: 'Map'),
        Token(tokenType: TokenType.symbol, data: '<'),
        Token(tokenType: TokenType.id, data: 'App_Item21'),
        Token(tokenType: TokenType.symbol, data: ','),
        Token(tokenType: TokenType.id, data: '_Item015'),
        Token(tokenType: TokenType.symbol, data: '>'),
        Token(tokenType: TokenType.symbol, data: '>'),
      ],
    );
  });

  test('tokenize compound with spaces 2', () async {
    expect(
      tokenize(StringStream('  Optional<  Map < App_Item21, Optional  < _Item015>   >  > ')),
      [
        Token(tokenType: TokenType.id, data: 'Optional'),
        Token(tokenType: TokenType.symbol, data: '<'),
        Token(tokenType: TokenType.id, data: 'Map'),
        Token(tokenType: TokenType.symbol, data: '<'),
        Token(tokenType: TokenType.id, data: 'App_Item21'),
        Token(tokenType: TokenType.symbol, data: ','),
        Token(tokenType: TokenType.id, data: 'Optional'),
        Token(tokenType: TokenType.symbol, data: '<'),
        Token(tokenType: TokenType.id, data: '_Item015'),
        Token(tokenType: TokenType.symbol, data: '>'),
        Token(tokenType: TokenType.symbol, data: '>'),
        Token(tokenType: TokenType.symbol, data: '>'),
      ],
    );
  });

  test('tokenize id with numbers', () async {
    expect(
      tokenize(StringStream('123Map')),
      [
        Token(tokenType: TokenType.symbol, data: '1'),
        Token(tokenType: TokenType.symbol, data: '2'),
        Token(tokenType: TokenType.symbol, data: '3'),
        Token(tokenType: TokenType.id, data: 'Map'),
      ],
    );
  });

  test('tokenize id separated by spaces', () async {
    expect(
      tokenize(StringStream('Map List Set')),
      [
        Token(tokenType: TokenType.id, data: 'Map'),
        Token(tokenType: TokenType.id, data: 'List'),
        Token(tokenType: TokenType.id, data: 'Set'),
      ],
    );
  });
}
