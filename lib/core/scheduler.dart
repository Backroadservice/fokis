import 'interpolator.dart';
import 'event_store.dart';

class AppliedFrame {
  final double panX, panY, scale, angle, alpha;
  const AppliedFrame({this.panX=0, this.panY=0, this.scale=1.0, this.angle=0, this.alpha=1.0});
  AppliedFrame copyWith({double? panX, double? panY, double? scale, double? angle, double? alpha}) =>
    AppliedFrame(
      panX: panX ?? this.panX,
      panY: panY ?? this.panY,
      scale: scale ?? this.scale,
      angle: angle ?? this.angle,
      alpha: alpha ?? this.alpha,
    );
}

class Scheduler {
  final EventStore store;
  Scheduler(this.store);

  AppliedFrame evaluate(int ptsMs) {
    final e = _resolveEvent(ptsMs);
    if (e == null) return const AppliedFrame();
    final local = _localMs(e, ptsMs);
    return _applyEvent(e, local);
  }

  void reschedule(int ptsMs) {/* no-op for now; hook for prefetch/seek */}

  Event? _resolveEvent(int ptsMs) {
    Event? chosen;
    int chosenStart = -1;
    for (final t in store.timeline) {
      final e = store.events[t.eventId]!;
      final start = t.ptsMs;
      final end = start + e.durationMs;
      if (ptsMs >= start && ptsMs < end) {
        if (start > chosenStart) { chosen = e; chosenStart = start; }
      }
    }
    return chosen;
  }

  int _localMs(Event e, int ptsMs) {
    for (final t in store.timeline) {
      if (t.eventId == e.eventId) return (ptsMs - t.ptsMs).clamp(0, e.durationMs);
    }
    return 0;
  }

  AppliedFrame _applyEvent(Event e, int localMs) {
    double panX=0, panY=0, scale=1, angle=0, alpha=1;
    for (final act in e.actions) {
      for (final ch in act.channels) {
        if (ch.keys.isEmpty) continue;
        // segment
        var left = ch.keys.first;
        var right = ch.keys.last;
        for (int i=1;i<ch.keys.length;i++){
          if (localMs < ch.keys[i].offsetMs){ right = ch.keys[i]; left = ch.keys[i-1]; break; }
        }
        final segDur = (right.offsetMs - left.offsetMs).abs().clamp(1, e.durationMs);
        final segT = ((localMs - left.offsetMs) / segDur).clamp(0.0, 1.0);
        final easing = _parseEasing(left.easing);
        final eased = Interpolator.sample(easing, segT);
        final v = left.value + (right.value - left.value) * eased;
        switch (ch.channelId) {
          case 'CH_X': panX = v; break;
          case 'CH_Y': panY = v; break;
          case 'CH_SCALE': scale = v; break;
          case 'CH_ANGLE': angle = v; break;
          case 'CH_ALPHA': alpha = v; break;
        }
      }
    }
    return AppliedFrame(panX:panX, panY:panY, scale:scale, angle:angle, alpha:alpha);
  }

  Easing _parseEasing(String s){
    switch(s){
      case 'EASE_IN': return Easing.easeIn;
      case 'EASE_OUT': return Easing.easeOut;
      case 'EASE_IN_OUT': return Easing.easeInOut;
      default: return Easing.linear;
    }
  }
}
