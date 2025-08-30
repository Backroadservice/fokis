class TelemetryLogger {
  void log(String name, Map<String, Object?> fields) {
    final ts = DateTime.now().toIso8601String();
    // For now, just print. Later wire to server.
    // ignore: avoid_print
    print('[telemetry] $ts $name ${fields.toString()}');
  }
}
