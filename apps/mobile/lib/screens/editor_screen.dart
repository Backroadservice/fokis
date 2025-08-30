import 'package:flutter/material.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});
  @override Widget build(BuildContext c){
    return Scaffold(
      appBar: AppBar(title: const Text('エディタ（最小雛形）')),
      body: const Center(child: Text('ここに Timeline / Inspector / Viewer を配置（後で差し替え）')),
    );
  }
}
