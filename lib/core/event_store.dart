enum EventType { zoom, pan, rotate, opacity, marker, comment, custom }

class Keyframe {
  final int offsetMs;
  final double value;
  final String easing; // 'linear','easeIn','easeOut','easeInOut'
  const Keyframe(this.offsetMs, this.value, this.easing);
}

class Channel {
  final String channelId; // CH_X, CH_Y, CH_SCALE, CH_ANGLE, CH_ALPHA
  final List<Keyframe> keys;
  const Channel(this.channelId, this.keys);
}

class Action {
  final String actionType; // AT_PAN, AT_ZOOM, ...
  final List<Channel> channels;
  const Action(this.actionType, this.channels);
}

class Event {
  final String eventId;
  final EventType type;
  final int durationMs;
  final List<Action> actions;
  const Event({required this.eventId, required this.type, required this.durationMs, required this.actions});
}

class TimelineEntry {
  final int ptsMs;
  final String eventId;
  const TimelineEntry(this.ptsMs, this.eventId);
}

class ViewModel {
  final Map<String, Event> events;
  final List<TimelineEntry> timeline;
  const ViewModel(this.events, this.timeline);
}

class EventStore {
  final Map<String, Event> events = {};
  final List<TimelineEntry> timeline = <TimelineEntry>[];

  Event? find(String id) => events[id];

  List<TimelineEntry> between(int startMs, int endMs) =>
      timeline.where((t) => t.ptsMs >= startMs && t.ptsMs < endMs).toList();

  void put(Event e, int startMs) {
    events[e.eventId] = e;
    timeline.add(TimelineEntry(startMs, e.eventId));
    timeline.sort((a,b) => a.ptsMs.compareTo(b.ptsMs));
  }
}
