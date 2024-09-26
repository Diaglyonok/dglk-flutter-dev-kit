extension ComparableExt<T> on Comparable<T>? {
  int compareToNullable(T? other) {
    if (this != null && other != null) {
      return this!.compareTo(other);
    }

    if (other == null && this != null) {
      return -1;
    }

    if (this == null && other != null) {
      return 1;
    }

    return 0;
  }
}
