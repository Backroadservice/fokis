import 'package:flutter/material.dart';

/// ---- 保存フローの定数＆マッピング（このファイルに内包） ----
enum SaveErrorKind { ok200, conflict409, size413, schema422, timeout408, server5xx }
enum UiAction { toastSaved, goConflict, showLimitDialog, showSchemaDialog, showRetrySnackBar }

SaveErrorKind classify(int status) {
  switch (status) {
    case 200: return SaveErrorKind.ok200;
    case 409: return SaveErrorKind.conflict409;
    case 413: return SaveErrorKind.size413;
    case 422: return SaveErrorKind.schema422;
    case 408: return SaveErrorKind.timeout408;
    default:  return SaveErrorKind.server5xx;
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

const bool kForceConflictResolverForDemo = true;

/// ---- 競合解決スタブ ----
class ConflictResolveScreen extends StatelessWidget {
  const ConflictResolveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('競合の解決（デモ）')),
      body: const Center(
        child: Text(
          'DiffList + SplitPreview（プレースホルダ）\nここが開けばOK',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// ---- 保存UI分岐デモ画面（const対応）----
class SaveFlowDemoScreen extends StatelessWidget {
  const SaveFlowDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('保存UI分岐デモ')),
      body: Center(
        child: Wrap(
          spacing: 16, runSpacing: 16,
          children: [
            _btn(context, 'OK (200)', 200),
            _btn(context, 'Conflict (409)', 409),
            _btn(context, 'Too Large (413)', 413),
            _btn(context, 'Unprocessable (422)', 422),
            _btn(context, 'Timeout (408)', 408),
            _btn(context, 'Server (500)', 500),
          ],
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, String label, int status) {
    return ElevatedButton(
      onPressed: () => handleSaveResponse(context, status, idemKey: 'demo-123'),
      child: Text(label),
    );
  }
}

/// ---- 実際の UI 分岐 ----
void handleSaveResponse(BuildContext context, int status, {String? idemKey}) {
  final kind = classify(status);
  // ★ ここで非 null 化（デフォルトは toastSaved）
  final UiAction action = kSaveUiRoute[kind] ?? UiAction.toastSaved;

  debugPrint('save_flow: status=$status kind=$kind ui=$action');

  switch (action) {
    case UiAction.toastSaved:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存完了 (200)')),
      );
      break;

    case UiAction.goConflict:
      // SnackBar + すぐに Resolver へ遷移（見逃し防止）
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('409: 競合を検出しました'),
          action: SnackBarAction(
            label: '開く',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ConflictResolveScreen()),
              );
            },
          ),
        ),
      );
      if (kForceConflictResolverForDemo) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ConflictResolveScreen()),
        );
      }
      break;

    case UiAction.showLimitDialog:
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('サイズ/件数 上限超過 (413)'),
          content: Text('イベント削減または圧縮設定を見直してください。'),
        ),
      );
      break;

    case UiAction.showSchemaDialog:
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('内容不整合 (422)'),
          content: Text('データを再生成して保存をお試しください。'),
        ),
      );
      break;

    case UiAction.showRetrySnackBar:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('再送します (status=$status) ${idemKey != null ? '(idem=$idemKey)' : ''}'),
          duration: const Duration(seconds: 4),
        ),
      );
      break;
  }
}
