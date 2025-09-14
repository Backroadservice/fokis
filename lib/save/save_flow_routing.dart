/// 保存APIのHTTPステータスをUI動作にマップする純Dart層。
/// Flutter/UI からは SaveRouting.routeFor(status) を呼ぶだけにする。
library save_flow_routing;

/// 競合リゾルバの有効/無効（本番は false → Canary で true）
const bool conflictResolverEnabled = true;

/// UI側で取り得る分岐
enum UiRoute {
  stay,                   // そのまま（SnackBar等）
  closeEditor,            // 完了 → エディタを閉じる
  openConflictResolver,   // 競合解決画面へ
  showDialog,             // ダイアログ表示（致命/案内）
}

/// ルーティング結果（UIに渡す最低限の情報）
class SaveRoutingDecision {
  final UiRoute route;
  final String message;     // 表示メッセージ
  final bool canRetry;      // 再試行可能か
  final bool showOpenAction; // SnackBarに「開く」等のアクションを出すか（409想定）

  const SaveRoutingDecision({
    required this.route,
    required this.message,
    this.canRetry = false,
    this.showOpenAction = false,
  });

  @override
  String toString() =>
      'SaveRoutingDecision(route=$route, canRetry=$canRetry, showOpenAction=$showOpenAction, msg="$message")';
}

/// メインのマッピング関数
SaveRoutingDecision routeForHttp(int status, {bool resolverEnabled = conflictResolverEnabled}) {
  switch (status) {
    case 200:
    case 201:
      return const SaveRoutingDecision(
        route: UiRoute.closeEditor,
        message: '保存しました',
        canRetry: false,
      );

    case 409:
      if (resolverEnabled) {
        return const SaveRoutingDecision(
          route: UiRoute.openConflictResolver,
          message: 'サーバー側で更新がありました（競合）。解決しますか？',
          canRetry: false,
          showOpenAction: true,
        );
      } else {
        return const SaveRoutingDecision(
          route: UiRoute.stay,
          message: '競合が発生しました（後で解決画面を提供）',
          canRetry: true,
          showOpenAction: false,
        );
      }

    case 413: // Payload Too Large
      return const SaveRoutingDecision(
        route: UiRoute.showDialog,
        message: '保存データが大きすぎます。クリップ数や解像度を下げてください。',
        canRetry: false,
      );

    case 422: // Unprocessable Entity
      return const SaveRoutingDecision(
        route: UiRoute.showDialog,
        message: '入力に不備があります。ハイライト箇所を修正のうえ再保存してください。',
        canRetry: true,
      );

    case 408: // Request Timeout
      return const SaveRoutingDecision(
        route: UiRoute.stay,
        message: 'タイムアウトしました。ネットワークをご確認のうえ再試行してください。',
        canRetry: true,
      );

    default:
      if (status >= 500 && status < 600) {
        return const SaveRoutingDecision(
          route: UiRoute.stay,
          message: 'サーバーエラーが発生しました。しばらくしてから再試行してください。',
          canRetry: true,
        );
      }
      return SaveRoutingDecision(
        route: UiRoute.stay,
        message: '未定義のステータスを受信しました（$status）。',
        canRetry: true,
      );
  }
}
