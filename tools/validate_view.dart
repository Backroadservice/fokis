import 'dart:convert';
import 'dart:io';

void main(List<String> args){
  if (args.length < 2) {
    stderr.writeln('Usage: dart validate_view.dart <max_bytes> <max_events>');
    exit(64);
  }
  final maxBytes = int.parse(args[0]);
  final maxEvents = int.parse(args[1]);
  final stdinText = stdin.readAsStringSync();
  final data = jsonDecode(stdinText);
  final encoded = utf8.encode(jsonEncode(data)); // proxy for size before protobuf
  final sizeOk = encoded.length <= maxBytes;
  final events = (data['timeline'] as List?)?.length ?? 0;
  final eventsOk = events <= maxEvents;
  print('size_ok=$sizeOk (${encoded.length}/$maxBytes), events_ok=$eventsOk ($events/$maxEvents)');
  if (!(sizeOk && eventsOk)) exit(2);
}
