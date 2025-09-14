import "package:test/test.dart";
import "../lib/save/save_flow_routing.dart";

void main() {
  group("Save routing", () {
    test("200/201 �� closeEditor", () {
      final d200 = routeForHttp(200);
      final d201 = routeForHttp(201);
      expect(d200.route, UiRoute.closeEditor);
      expect(d201.route, UiRoute.closeEditor);
    });

    test("409 �� conflictResolver or stay (flag)", () {
      final on  = routeForHttp(409, resolverEnabled: true);
      final off = routeForHttp(409, resolverEnabled: false);
      expect(on.route, UiRoute.openConflictResolver);
      expect(on.showOpenAction, true);
      expect(off.route, UiRoute.stay);
      expect(off.canRetry, true);
    });

    test("413 �� showDialog (no retry)", () {
      final d = routeForHttp(413);
      expect(d.route, UiRoute.showDialog);
      expect(d.canRetry, false);
    });

    test("422 �� showDialog (retry)", () {
      final d = routeForHttp(422);
      expect(d.route, UiRoute.showDialog);
      expect(d.canRetry, true);
    });

    test("408 �� stay (retry)", () {
      final d = routeForHttp(408);
      expect(d.route, UiRoute.stay);
      expect(d.canRetry, true);
    });

    test("5xx �� stay (retry)", () {
      final d = routeForHttp(503);
      expect(d.route, UiRoute.stay);
      expect(d.canRetry, true);
    });

    test("unknown �� stay (retry)", () {
      final d = routeForHttp(499);
      expect(d.route, UiRoute.stay);
      expect(d.canRetry, true);
    });
  });
}
