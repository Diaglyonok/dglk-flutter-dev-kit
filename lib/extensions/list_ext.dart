extension ListExtNullable<E> on List<E?>? {
  bool isNullOrEmpty() => (this == null) || this!.isEmpty;
  bool isNotNullOrEmpty() => !isNullOrEmpty();
  List<E?>? getSorted<E>([int? Function(E?, E?)? compare]) {
    if (this == null) {
      return null;
    }

    List<E?> newList = this!.map((e) => e).toList().cast<E>();
    if (compare == null && E is Comparable) {
      newList.sort();
    } else if (compare != null) {
      newList.sort(compare as int Function(E?, E?)?);
    }
    return newList;
  }

  List? copy() => this == null ? null : this!.map((e) => e).toList();

  bool indexValid(int index) {
    if (isNullOrEmpty()) {
      return false;
    }

    if (index >= this!.length || index < 0) {
      return false;
    }

    return true;
  }
}
