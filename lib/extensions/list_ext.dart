extension ListExtNullable<E> on List<E>? {
  bool isNullOrEmpty() => (this == null) || this!.isEmpty;
  bool isNotNullOrEmpty() => !isNullOrEmpty();
}

extension ListExtNonNullable<E> on List<E> {
  List<E> copy() => map((e) => e).toList();

  bool indexValid(int index) {
    if (isNullOrEmpty()) {
      return false;
    }

    if (index >= length || index < 0) {
      return false;
    }

    return true;
  }

  List<E> getSorted([int? Function(E, E)? compare]) {
    List<E> newList = map((e) => e).toList().cast<E>();
    if (compare == null && E is Comparable) {
      newList.sort();
    } else if (compare != null) {
      newList.sort(compare as int Function(E?, E?)?);
    }
    return newList;
  }
}
