import "package:test/test.dart";
import "dart:convert";
import "../apps/mobile/lib/conflict/conflict_model.dart";

void main() {
  test("DiffSummary.compare basic add/remove/modify", () {
    final a = {"title":"A", "tags":["x","y"], "count":1};
    final b = {"title":"B", "tags":["x","y"], "extra":true};

    final diff = DiffSummary.compare(a, b);
    expect(diff.whereOp(DiffOp.modify).length, 1);
    expect(diff.whereOp(DiffOp.add).length, 1);
    expect(diff.whereOp(DiffOp.remove).length, 1);

    final m = diff.whereOp(DiffOp.modify).first;
    expect(m.key, "title");
    expect(m.a, "A");
    expect(m.b, "B");
  });

  test("Deep equals handles nested maps/lists", () {
    final a = jsonDecode(r"""{"a":[1,{"x":2}],"b":{"c":3}}""");
    final b = jsonDecode(r"""{"a":[1,{"x":2}],"b":{"c":3}}""");
    final d = DiffSummary.compare(a, b);
    expect(d.isEmpty, isTrue);
  });
}
