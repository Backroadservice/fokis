import "package:collection/collection.dart";
import "../editor/models.dart";

enum DiffKind { add, remove, change }

class DiffEntry {
  final String id;
  final DiffKind kind;
  final TimelineEvent? a; // 旧
  final TimelineEvent? b; // 新
  const DiffEntry({required this.id, required this.kind, this.a, this.b});
}

class DiffSummary {
  final List<DiffEntry> entries;
  const DiffSummary(this.entries);

  static final _mapEq = const DeepCollectionEquality().equals;

  static bool _eventEquals(TimelineEvent x, TimelineEvent y) {
    return x.id == y.id &&
        x.type == y.type &&
        x.startMs == y.startMs &&
        x.endMs == y.endMs &&
        _mapEq(x.keys, y.keys);
  }

  /// タイムライン A→B の差分をイベント粒度で計算
  static DiffSummary compare(Timeline a, Timeline b) {
    final ma = {for (final e in a) e.id: e};
    final mb = {for (final e in b) e.id: e};
    final ids = {...ma.keys, ...mb.keys}.toList()..sort();
    final list = <DiffEntry>[];

    for (final id in ids) {
      final ea = ma[id];
      final eb = mb[id];
      if (ea != null && eb == null) {
        list.add(DiffEntry(id: id, kind: DiffKind.remove, a: ea));
      } else if (ea == null && eb != null) {
        list.add(DiffEntry(id: id, kind: DiffKind.add, b: eb));
      } else if (ea != null && eb != null && !_eventEquals(ea, eb)) {
        list.add(DiffEntry(id: id, kind: DiffKind.change, a: ea, b: eb));
      }
    }
    return DiffSummary(list);
  }

  /// 採否マップで B 案を適用（true= B を採用 / false = Aを維持）
  ///
  /// - add:   true で追加、false で追加しない
  /// - remove:true で削除、false で残す
  /// - change:true で置換、false で据え置き
  static Timeline apply({
    required Timeline baseA,
    required Timeline targetB,
    required Map<String, bool> acceptBById,
  }) {
    final ma = {for (final e in baseA) e.id: e};
    final mb = {for (final e in targetB) e.id: e};
    final diff = compare(baseA, targetB);

    for (final d in diff.entries) {
      final accept = acceptBById[d.id] ?? false;
      switch (d.kind) {
        case DiffKind.add:
          if (accept && d.b != null) ma[d.id] = d.b!;
          break;
        case DiffKind.remove:
          if (accept) ma.remove(d.id);
          break;
        case DiffKind.change:
          if (accept && d.b != null) {
            ma[d.id] = d.b!;
          } // accept=false なら何もしない
          break;
      }
    }
    // 安定化のため ID ソート
    final out = ma.values.toList()
      ..sort((x, y) => x.id.compareTo(y.id));
    return out;
  }
}
