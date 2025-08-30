import 'package:test/test.dart';
import '../lib/save/save_flow_routing_for_tests.dart';

void main(){
  test('HTTP→UI mapping', () {
    expect(kSaveUiRoute[classify(200)], UiAction.toastSaved);
    expect(kSaveUiRoute[classify(409)], UiAction.goConflict);
    expect(kSaveUiRoute[classify(413)], UiAction.showLimitDialog);
    expect(kSaveUiRoute[classify(422)], UiAction.showSchemaDialog);
    expect(kSaveUiRoute[classify(408)], UiAction.showRetrySnackBar);
    expect(kSaveUiRoute[classify(503)], UiAction.showRetrySnackBar);
  });
}
