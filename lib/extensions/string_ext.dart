extension StringExt on String? {
  bool isNullOrEmpty() => (this == null) || this!.isEmpty;

  bool isNotNullOrEmpty() => !isNullOrEmpty();

  bool containsSafe(Pattern? pattern, [int startIndex = 0]) {
    if (pattern == null || isNullOrEmpty()) {
      return false;
    }

    return this!.contains(pattern);
  }

  T? toEnum<T>(List<T> values) {
    if (this != null) {
      final str = this!.toLowerCase();
      for (T enumValue in values) {
        final enumStr = enumValue.toString();
        final index = enumStr.lastIndexOf('.');
        final value = (index >= 0) ? enumStr.substring(index + 1) : enumStr;
        if (value.toLowerCase() == str) {
          return enumValue;
        }
      }
    }
    return null;
  }
}
