import 'package:test/test.dart';
import '../apps/mobile/lib/editor/models.dart';
import '../apps/mobile/lib/editor/editor_commands_impl.dart';

void main() {
  test('EditorOps basic ops + undo/redo', () {
    final ctrl = EditorController();

    // add
    final e1 = TimelineEvent(
      id: 'e1',
      type: EventType.text,
      startMs: 0,
      endMs: 1000,
      keys: const {'x': 0, 'y': 0},
    );
    ctrl.apply(EditorOps.add(e1));
    expect(ctrl.state.events.length, 1);
    expect(ctrl.state.selectedId, 'e1');

    // move
    ctrl.apply(EditorOps.move('e1', startMs: 100, endMs: 900));
    expect(ctrl.state.events.first.startMs, 100);

    // changeType
    ctrl.apply(EditorOps.changeType('e1', EventType.sticker));
    expect(ctrl.state.events.first.type, EventType.sticker);

    // editKeys (merge + removeNulls)
    ctrl.apply(EditorOps.editKeys('e1', {'x': 10, 'y': null, 'color': '#fff'}));
    final k = ctrl.state.events.first.keys;
    expect(k.containsKey('y'), isFalse);
    expect(k['x'], 10);
    expect(k['color'], '#fff');

    // undo / redo
    expect(ctrl.canUndo(), isTrue);
    ctrl.undo(); // undo editKeys
    expect(ctrl.state.events.first.keys.containsKey('color'), isFalse);
    ctrl.redo();
    expect(ctrl.state.events.first.keys['color'], '#fff');

    // remove
    ctrl.apply(EditorOps.remove('e1'));
    expect(ctrl.state.events, isEmpty);
    ctrl.undo(); // back
    expect(ctrl.state.events.length, 1);
  });

  test('duplicate/add & notfound/move throw', () {
    final ctrl = EditorController();
    final e = TimelineEvent(id: 'a', type: EventType.text, startMs: 0, endMs: 10);
    ctrl.apply(EditorOps.add(e));
    expect(() => ctrl.apply(EditorOps.add(e)), throwsStateError);
    expect(() => ctrl.apply(EditorOps.move('nope', startMs: 0, endMs: 1)), throwsStateError);
  });
}
