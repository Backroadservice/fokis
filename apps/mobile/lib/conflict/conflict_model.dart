import "package:collection/collection.dart";
import "../editor/models.dart";

enum DiffKind { add, remove, change }

class DiffEntry {
  final String id;
  final DiffKind kind;
  final TimelineEvent? a; // ��
  final TimelineEvent? b; // �V
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

  /// �^�C�����C�� A��B �̍������C�x���g���x�Ōv�Z
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

  /// �̔ۃ}�b�v�� B �Ă�K�p�itrue= B ���̗p / false = A���ێ��j
  ///
  /// - add:   true �Œǉ��Afalse �Œǉ����Ȃ�
  /// - remove:true �ō폜�Afalse �Ŏc��
  /// - change:true �Œu���Afalse �Ő����u��
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
          } // accept=false �Ȃ牽�����Ȃ�
          break;
      }
    }
    // ���艻�̂��� ID �\�[�g
    final out = ma.values.toList()
      ..sort((x, y) => x.id.compareTo(y.id));
    return out;
  }
}
