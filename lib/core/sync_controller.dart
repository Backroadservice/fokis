import 'scheduler.dart';

/// Sync delta 補正（hysteresisMs）。
/// 初回/大きなドリフト時は reschedule、毎ティック evaluate を呼び出す。
class SyncController {
  final Scheduler scheduler;
  final int hysteresisMs;
  int? _lastPts;

  SyncController({required this.scheduler, this.hysteresisMs = 33});

  /// プレイヤーからの PTS 通知。現在の AppliedFrame を返す。
  AppliedFrame onPts(int ptsMs) {
    final last = _lastPts;
    if (last == null) {
      // 初回は現在 PTS に合わせて再スケジュール
      scheduler.reschedule(ptsMs);
    } else {
      final delta = ptsMs - last;
      if (delta.abs() > hysteresisMs) {
        // 閾値超過  ジャンプ同期
        scheduler.reschedule(ptsMs);
      }
    }
    final frame = scheduler.evaluate(ptsMs); // いまのフレームを評価して返す
    _lastPts = ptsMs;
    return frame;
  }

  /// バッファ開始時（必要なら将来拡張）
  void onBufferingStart() {}

  /// バッファ復帰時：再スケジュールして即評価したフレームを返す。
  AppliedFrame onBufferingEnd(int ptsMs) {
    scheduler.reschedule(ptsMs);
    final frame = scheduler.evaluate(ptsMs);
    _lastPts = ptsMs;
    return frame;
  }
}
