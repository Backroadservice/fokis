import 'dart:async';

enum PlayerState { idle, loading, ready, playing, paused, buffering }

class FakePlayerFacade {
  final _ptsCtrl = StreamController<int>.broadcast();
  Stream<int> get pts$ => _ptsCtrl.stream;
  int _pts = 0;
  Timer? _tm;
  PlayerState state = PlayerState.idle;

  Future<void> play() async {
    state = PlayerState.playing;
    _tm?.cancel();
    _tm = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _pts += 16;
      _ptsCtrl.add(_pts);
    });
  }
  Future<void> pause() async {
    _tm?.cancel();
    state = PlayerState.paused;
  }
  Future<void> seek(int ptsMs) async {
    _pts = ptsMs;
    _ptsCtrl.add(_pts);
  }
  void dispose(){ _tm?.cancel(); _ptsCtrl.close(); }
}
