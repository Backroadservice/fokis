import 'scheduler.dart';

/// Sync delta 補正の参照実装（±hysteresisMs）。
/// 初回/大きなドリフト時は reschedule、毎ティック evaluate。
class SyncController {
  final Scheduler scheduler;
  final int hysteresisMs;

  int? _lastPts;

  SyncController({required this.scheduler, this.hysteresisMs = 33});

  /// プレイヤーからの PTS 通知ごとに呼ぶ。
  void onPts(int ptsMs) {
    final last = _lastPts;
    if (last == null) {
      // 初回は評価点を現在に合わせて再スケジューリング
      scheduler.reschedule(ptsMs);
    } else {
      final delta = ptsMs - last;
      if (delta.abs() > hysteresisMs) {
        // 閾値超過 → ジャンプ同期
        scheduler.reschedule(ptsMs);
      }
    }
    // 常に現在 PTS で評価（Pan/Zoom/Rotate/Opacity 計算）
    scheduler.evaluate(ptsMs);
    _lastPts = ptsMs;
  }

  /// バッファ開始時のフック（現状は no-op）
  void onBufferingStart() {}

  /// バッファ復帰時は現在 PTS に合わせて再スケジュール＋即評価。
  void onBufferingEnd(int ptsMs) {
    scheduler.reschedule(ptsMs);
    scheduler.evaluate(ptsMs);
    _lastPts = ptsMs;
  }
}
