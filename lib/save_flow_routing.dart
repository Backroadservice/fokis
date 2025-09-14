enum SaveUi {
  okSnackbar,        // 200
  openResolver,      // 409
  tooLargeDialog,    // 413
  validationDialog,  // 422
  timeoutRetry,      // 408
  serverErrorDialog, // 5xx or others
}

class SaveResponse {
  final int status;
  const SaveResponse(this.status);
}

/// HTTP ステータスを UI へマップする純関数（契約の土台）
SaveUi routeSave(SaveResponse r) {
  final s = r.status;
  if (s == 200) return SaveUi.okSnackbar;
  if (s == 409) return SaveUi.openResolver;
  if (s == 413) return SaveUi.tooLargeDialog;
  if (s == 422) return SaveUi.validationDialog;
  if (s == 408) return SaveUi.timeoutRetry;
  if (s >= 500 && s < 600) return SaveUi.serverErrorDialog;
  return SaveUi.serverErrorDialog; // フォールバック
}
