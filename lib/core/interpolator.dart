import 'dart:math' as math;
enum Easing { linear, easeIn, easeOut, easeInOut }

class Interpolator {
  static double sample(Easing easing, double t) {
    t = t.clamp(0.0, 1.0);
    switch (easing) {
      case Easing.linear:   return t;
      case Easing.easeIn:   return _cubicBezierY(t, 0.42, 0.0, 1.0, 1.0);
      case Easing.easeOut:  return _cubicBezierY(t, 0.0, 0.0, 0.58, 1.0);
      case Easing.easeInOut:return _cubicBezierY(t, 0.42, 0.0, 0.58, 1.0);
    }
  }
  static double _cubicBezierY(double t, double x1, double y1, double x2, double y2) {
    double lo = 0.0, hi = 1.0;
    for (int i=0;i<50;i++) {
      final mid = (lo + hi) * 0.5;
      final x = _bezierX(mid, x1, x2);
      if (x < t) lo = mid; else hi = mid;
    }
    final s = (lo + hi) * 0.5;
    return _bezierY(s, y1, y2);
  }
  static double _bezierX(double s, double x1, double x2) {
    final inv = 1 - s;
    return 3*inv*inv*s*x1 + 3*inv*s*s*x2 + s*s*s;
  }
  static double _bezierY(double s, double y1, double y2) {
    final inv = 1 - s;
    return 3*inv*inv*s*y1 + 3*inv*s*s*y2 + s*s*s;
  }
}
