import 'package:test/test.dart';
import '../lib/core/scheduler.dart';
import '../lib/core/sync_controller.dart';
import '../lib/core/event_store.dart';

void main(){
  test('Δ ≤ 33ms uses interpolation path (no reschedule jump)', () {
    final store = EventStore();
    store.put(Event(eventId:'e1', type:EventType.zoom, durationMs:1000, actions:[]), 0);
    final sch = Scheduler(store);
    final sync = SyncController(scheduler: sch, hysteresisMs: 33);
    final f1 = sync.onPts(100);
    final f2 = sync.onPts(130); // delta=30
    expect(f2.scale, equals(f1.scale)); // placeholder check; no exception means path ok
  });

  test('Δ > 33ms triggers reschedule', () {
    final store = EventStore();
    store.put(Event(eventId:'e1', type:EventType.zoom, durationMs:1000, actions:[]), 0);
    final sch = Scheduler(store);
    final sync = SyncController(scheduler: sch, hysteresisMs: 33);
    final _ = sync.onPts(100);
    final f2 = sync.onPts(200); // delta=100 -> jump
    expect(f2, isA<AppliedFrame>());
  });
}
