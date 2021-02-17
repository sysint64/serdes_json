String removeSchemeSuffix(String type) {
  if (type.endsWith('Scheme')) {
    return type.substring(0, type.length - 'Scheme'.length);
  } else {
    return type;
  }
}

bool isPrimitive(String type) {
  return ['String', 'int', 'num', 'bool', 'double'].contains(type);
}
