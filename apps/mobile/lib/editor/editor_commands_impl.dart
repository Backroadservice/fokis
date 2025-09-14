import 'models.dart';

/// 不変なユーティリティ
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

/// 変更は純関数（EditorState -> EditorState）として定義
typedef EditorOperation = EditorState Function(EditorState s);

class EditorOps {
  /// 追加：ID重複はエラー
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

  /// 削除：存在しなければエラー
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

  /// 時間移動：start < end の検証あり
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

  /// 種別変更
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

  /// keys をパッチ（merge=true ならマージ、false なら置換）
  /// removeNulls=true の場合、value=null を削除扱いにする
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

/// 超シンプルな Undo/Redo コントローラ（スナップショット方式）
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
