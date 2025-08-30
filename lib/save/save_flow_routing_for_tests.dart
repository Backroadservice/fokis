enum SaveErrorKind { ok200, conflict409, size413, schema422, timeout408, server5xx }
enum UiAction { toastSaved, goConflict, showLimitDialog, showSchemaDialog, showRetrySnackBar }

SaveErrorKind classify(int status) {
  switch (status) {
    case 200: return SaveErrorKind.ok200;
    case 409: return SaveErrorKind.conflict409;
    case 413: return SaveErrorKind.size413;
    case 422: return SaveErrorKind.schema422;
    case 408: return SaveErrorKind.timeout408;
    default: return SaveErrorKind.server5xx;
  }
}

const Map<SaveErrorKind, UiAction> kSaveUiRoute = {
  SaveErrorKind.ok200: UiAction.toastSaved,
  SaveErrorKind.conflict409: UiAction.goConflict,
  SaveErrorKind.size413: UiAction.showLimitDialog,
  SaveErrorKind.schema422: UiAction.showSchemaDialog,
  SaveErrorKind.timeout408: UiAction.showRetrySnackBar,
  SaveErrorKind.server5xx: UiAction.showRetrySnackBar,
};
