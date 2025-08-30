import 'scheduler.dart';

class SyncController {
  final Scheduler scheduler;
  final int hysteresisMs;
  int? _lastAppliedPts;

  SyncController(this.scheduler, {this.hysteresisMs = 33});

  AppliedFrame onPts(int ptsMs) {
    if (_lastAppliedPts == null) {
      _lastAppliedPts = ptsMs;
      return scheduler.evaluate(ptsMs);
    }
    final delta = ptsMs - _lastAppliedPts!;
    if (delta.abs() <= hysteresisMs) {
      final frame = scheduler.evaluate(ptsMs);
      _lastAppliedPts = ptsMs;
      return frame;
    } else {
      scheduler.reschedule(ptsMs);
      final snapped = scheduler.evaluate(ptsMs);
      _lastAppliedPts = ptsMs;
      return snapped;
    }
  }

  void onBufferingStart() { /* placeholder */ }
  void onBufferingEnd(int currentPtsMs) { scheduler.reschedule(currentPtsMs); }
}
