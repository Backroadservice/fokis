import "package:test/test.dart";
import "../apps/mobile/lib/editor/models.dart";
import "../apps/mobile/lib/conflict/conflict_model.dart";

TimelineEvent ev(String id, EventType t, int s, int e, [Map<String,Object?> k=const {}]) =>
  TimelineEvent(id: id, type: t, startMs: s, endMs: e, keys: k);

void main() {
  group("DiffSummary.compare & apply", () {
    test("add/remove/change を検出して採否適用できる", () {
      final a = <Timeline>[
        // A: e1(text), e2(sticker)
        [
          ev("e1", EventType.text, 0, 10, {"x":1}),
          ev("e2", EventType.sticker, 10, 20),
        ],
        // B: e1 を type 変更(text→sticker), e2 を削除, e3 を追加
        [
          ev("e1", EventType.sticker, 0, 10, {"x":1}), // change
          ev("e3", EventType.text, 30, 40),            // add
        ],
      ];

      final diff = DiffSummary.compare(a[0], a[1]);
      expect(diff.entries.map((d)=>d.kind).toSet(),
          containsAll({DiffKind.add, DiffKind.remove, DiffKind.change}));

      // 採否: e1= B を採用, e2= A を維持(削除拒否), e3= B を採用
      final merged = DiffSummary.apply(
        baseA: a[0],
        targetB: a[1],
        acceptBById: {"e1": true, "e2": false, "e3": true},
      );

      // 結果: e1(sticker), e2(sticker) 残る, e3(add) 入る
      expect(merged.length, 3);
      merged.sort((x,y)=>x.id.compareTo(y.id));
      final m = {for (final e in merged) e.id: e};
      expect(m["e1"]!.type, EventType.sticker);
      expect(m["e2"]!.type, EventType.sticker);
      expect(m.containsKey("e3"), isTrue);
    });
  });
}
