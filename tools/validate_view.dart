import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final input = await stdin.transform(utf8.decoder).join();
  if (input.isEmpty) {
    stderr.writeln('No input.');
    exitCode = 1;
    return;
  }
  // TODO: .fov1 ‚ğ‚±‚±‚ÅŒŸØ‚·‚é
  stdout.writeln('OK (${input.length} bytes)');
}
