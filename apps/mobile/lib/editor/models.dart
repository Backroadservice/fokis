import 'package:flutter/foundation.dart';

/// エディタ内のイベント種別（最小セット）
enum EventType { text, sticker, shape, subtitle }

/// タイムライン上のイベント（最小構成）
@immutable
class TimelineEvent {
  final String id;            // 一意ID
  final EventType type;       // 種別
  final int startMs;          // 開始（ms）
  final int endMs;            // 終了（ms）[startMs < endMs]
  final Map<String, Object?> keys; // 任意の属性（位置/サイズ/色など）

  const TimelineEvent({
    required this.id,
    required this.type,
    required this.startMs,
    required this.endMs,
    this.keys = const {},
  }) : assert(startMs < endMs, 'startMs must be < endMs');

  int get durationMs => endMs - startMs;

  TimelineEvent copyWith({
    String? id,
    EventType? type,
    int? startMs,
    int? endMs,
    Map<String, Object?>? keys,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      keys: keys ?? this.keys,
    );
  }
}

/// 単純なタイムライン表現（必要に応じてクラス化予定）
typedef Timeline = List<TimelineEvent>;

/// エディタ全体の状態（最小）
@immutable
class EditorState {
  final Timeline events;
  final String? selectedId;

  const EditorState({this.events = const [], this.selectedId});

  EditorState copyWith({Timeline? events, String? selectedId}) {
    return EditorState(
      events: events ?? this.events,
      selectedId: selectedId ?? this.selectedId,
    );
  }
}
