import 'models.dart';

/// �s�ςȃ��[�e�B���e�B
Timeline _clone(Timeline src) => List<TimelineEvent>.from(src);

int _idxById(Timeline list, String id) =>
    list.indexWhere((e) => e.id == id);

TimelineEvent _requireById(Timeline list, String id) {
  final i = _idxById(list, id);
  if (i < 0) {
    throw StateError('event not found: $id');
  }
  return list[i];
}

/// �ύX�͏��֐��iEditorState -> EditorState�j�Ƃ��Ē�`
typedef EditorOperation = EditorState Function(EditorState s);

class EditorOps {
  /// �ǉ��FID�d���̓G���[
  static EditorOperation add(TimelineEvent ev, {bool select = true}) {
    return (s) {
      final list = _clone(s.events);
      if (_idxById(list, ev.id) >= 0) {
        throw StateError('event already exists: ${ev.id}');
      }
      list.add(ev);
      return s.copyWith(
        events: list,
        selectedId: select ? ev.id : s.selectedId,
      );
    };
  }

  /// �폜�F���݂��Ȃ���΃G���[
  static EditorOperation remove(String id) {
    return (s) {
      final list = _clone(s.events);
      final i = _idxById(list, id);
      if (i < 0) throw StateError('event not found: $id');
      list.removeAt(i);
      final sel = s.selectedId == id ? null : s.selectedId;
      return s.copyWith(events: list, selectedId: sel);
    };
  }

  /// ���Ԉړ��Fstart < end �̌��؂���
  static EditorOperation move(String id, {required int startMs, required int endMs}) {
    assert(startMs < endMs, 'startMs must be < endMs');
    return (s) {
      final list = _clone(s.events);
      final i = _idxById(list, id);
      if (i < 0) throw StateError('event not found: $id');
      final old = list[i];
      list[i] = old.copyWith(startMs: startMs, endMs: endMs);
      return s.copyWith(events: list);
    };
  }

  /// ��ʕύX
  static EditorOperation changeType(String id, EventType type) {
    return (s) {
      final list = _clone(s.events);
      final i = _idxById(list, id);
      if (i < 0) throw StateError('event not found: $id');
      final old = list[i];
      list[i] = old.copyWith(type: type);
      return s.copyWith(events: list);
    };
  }

  /// keys ���p�b�`�imerge=true �Ȃ�}�[�W�Afalse �Ȃ�u���j
  /// removeNulls=true �̏ꍇ�Avalue=null ���폜�����ɂ���
  static EditorOperation editKeys(
    String id,
    Map<String, Object?> patch, {
    bool merge = true,
    bool removeNulls = true,
  }) {
    return (s) {
      final list = _clone(s.events);
      final i = _idxById(list, id);
      if (i < 0) throw StateError('event not found: $id');

      Map<String, Object?> next;
      if (merge) {
        next = Map<String, Object?>.from(list[i].keys);
        patch.forEach((k, v) {
          if (removeNulls && v == null) {
            next.remove(k);
          } else {
            next[k] = v;
          }
        });
      } else {
        next = Map<String, Object?>.from(patch);
        if (removeNulls) {
          next.removeWhere((_, v) => v == null);
        }
      }

      list[i] = list[i].copyWith(keys: next);
      return s.copyWith(events: list);
    };
  }
}

/// ���V���v���� Undo/Redo �R���g���[���i�X�i�b�v�V���b�g�����j
class EditorController {
  EditorState state;
  final List<EditorState> _undo = [];
  final List<EditorState> _redo = [];

  EditorController({EditorState? initial})
      : state = initial ?? const EditorState();

  void apply(EditorOperation op) {
    _undo.add(state);
    state = op(state);
    _redo.clear();
  }

  bool canUndo() => _undo.isNotEmpty;
  bool canRedo() => _redo.isNotEmpty;

  bool undo() {
    if (_undo.isEmpty) return false;
    _redo.add(state);
    state = _undo.removeLast();
    return true;
  }

  bool redo() {
    if (_redo.isEmpty) return false;
    _undo.add(state);
    state = _redo.removeLast();
    return true;
  }
}
