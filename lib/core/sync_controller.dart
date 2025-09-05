import 'scheduler.dart'; // Scheduler / AppliedFrame

/// Sync delta 補正（±hysteresisMs）。初回/大ドリフト時は reschedule、毎ティック evaluate。
class SyncController {
  final Scheduler scheduler;
  final int hysteresisMs;

  int? _lastPts;

  SyncController({required this.scheduler, this.hysteresisMs = 33});

  /// プレイヤーからの PTS 通知ごとに呼ぶ。最新の適用フレームを返す。
  AppliedFrame onPts(int ptsMs) {
    final last = _lastPts;
    if (last == null) {
      scheduler.reschedule(ptsMs);
    } else {
      final delta = ptsMs - last;
      if (delta.abs() > hysteresisMs) {
        scheduler.reschedule(ptsMs);
      }
    }
    final frame = scheduler.evaluate(ptsMs);
    _lastPts = ptsMs;
    return frame;
  }

  /// バッファ開始時（現状 no-op）
  void onBufferingStart() {}

  /// バッファ復帰時：現在 PTS に合わせて再スケジュールして即評価し、そのフレームを返す。
  AppliedFrame onBufferingEnd(int ptsMs) {
    scheduler.reschedule(ptsMs);
    final frame = scheduler.evaluate(ptsMs);
    _lastPts = ptsMs;
    return frame;
  }
}
