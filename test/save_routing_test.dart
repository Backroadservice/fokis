import "package:test/test.dart";
import "../lib/save_flow_routing.dart";

void main() {
  group("routeSave", () {
    test("maps HTTP to UI routes", () {
      expect(routeSave(const SaveResponse(200)), SaveUi.okSnackbar);
      expect(routeSave(const SaveResponse(409)), SaveUi.openResolver);
      expect(routeSave(const SaveResponse(413)), SaveUi.tooLargeDialog);
      expect(routeSave(const SaveResponse(422)), SaveUi.validationDialog);
      expect(routeSave(const SaveResponse(408)), SaveUi.timeoutRetry);
      expect(routeSave(const SaveResponse(500)), SaveUi.serverErrorDialog);
      expect(routeSave(const SaveResponse(502)), SaveUi.serverErrorDialog);
      expect(routeSave(const SaveResponse(503)), SaveUi.serverErrorDialog);
      // 未定義はフォールバック
      expect(routeSave(const SaveResponse(404)), SaveUi.serverErrorDialog);
    });
  });
}
