enum DiffOp { add, remove, modify }

class DiffEntry {
  final String key;
  final Object? a;
  final Object? b;
  final DiffOp op;
  const DiffEntry({required this.key, this.a, this.b, required this.op});
}

class DiffSummary {
  final List<DiffEntry> entries;
  const DiffSummary(this.entries);

  static DiffSummary compare(Map<String, Object?> a, Map<String, Object?> b) {
    final keys = <String>{...a.keys, ...b.keys}.toList()..sort();
    final out = <DiffEntry>[];
    for (final k in keys) {
      final hasA = a.containsKey(k);
      final hasB = b.containsKey(k);
      final va = hasA ? a[k] : null;
      final vb = hasB ? b[k] : null;

      if (hasA && !hasB) {
        out.add(DiffEntry(key: k, a: va, b: null, op: DiffOp.remove));
      } else if (!hasA && hasB) {
        out.add(DiffEntry(key: k, a: null, b: vb, op: DiffOp.add));
      } else if (!_deepEquals(va, vb)) {
        out.add(DiffEntry(key: k, a: va, b: vb, op: DiffOp.modify));
      }
    }
    return DiffSummary(out);
  }

  bool get isEmpty => entries.isEmpty;
  Iterable<DiffEntry> whereOp(DiffOp op) => entries.where((e) => e.op == op);
}

bool _deepEquals(Object? a, Object? b) {
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k)) return false;
      if (!_deepEquals(a[k], b[k])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}
