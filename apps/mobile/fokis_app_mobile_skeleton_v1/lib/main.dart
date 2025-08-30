import 'package:flutter/material.dart';
import 'screens/play_screen.dart';
import 'screens/editor_screen.dart';
import 'save/save_flow_ui.dart';

void main() => runApp(const FokisApp());

class FokisApp extends StatelessWidget {
  const FokisApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
      routes: {
        '/play': (_) => const PlayScreen(),
        '/editor': (_) => const EditorScreen(),
        '/save': (_) => const SaveFlowDemoScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fokis Mobile Skeleton')),
      body: Center(
        child: Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
          FilledButton(onPressed: ()=>Navigator.pushNamed(context, '/play'), child: const Text('再生デモ')),
          FilledButton.tonal(onPressed: ()=>Navigator.pushNamed(context, '/editor'), child: const Text('エディタ（最小）')),
          OutlinedButton(onPressed: ()=>Navigator.pushNamed(context, '/save'), child: const Text('保存UI分岐デモ')),
        ]),
      ),
    );
  }
}
