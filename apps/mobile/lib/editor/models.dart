import 'package:flutter/foundation.dart';

/// �G�f�B�^���̃C�x���g��ʁi�ŏ��Z�b�g�j
enum EventType { text, sticker, shape, subtitle }

/// �^�C�����C����̃C�x���g�i�ŏ��\���j
@immutable
class TimelineEvent {
  final String id;            // ���ID
  final EventType type;       // ���
  final int startMs;          // �J�n�ims�j
  final int endMs;            // �I���ims�j[startMs < endMs]
  final Map<String, Object?> keys; // �C�ӂ̑����i�ʒu/�T�C�Y/�F�Ȃǁj

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

/// �P���ȃ^�C�����C���\���i�K�v�ɉ����ăN���X���\��j
typedef Timeline = List<TimelineEvent>;

/// �G�f�B�^�S�̂̏�ԁi�ŏ��j
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
