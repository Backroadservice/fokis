import 'dart:async';
import 'package:flutter/material.dart';

/// 最小PTSタイマーを用いた疑似再生。後で PlayerFacade に置換。
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});
  @override State<PlayScreen> createState()=>_S();
}
class _S extends State<PlayScreen>{
  Timer? _tm; int _pts=0; bool _playing=false;
  void _toggle(){
    if (_playing) { _tm?.cancel(); setState(()=> _playing=false); }
    else {
      _tm = Timer.periodic(const Duration(milliseconds: 16), (_){
        setState(()=> _pts += 16);
      });
      setState(()=> _playing=true);
    }
  }
  @override void dispose(){ _tm?.cancel(); super.dispose(); }
  @override Widget build(BuildContext c){
    return Scaffold(
      appBar: AppBar(title: const Text('再生（疑似 PTS）')),
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children:[
        Text('PTS: ${_pts}ms', style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 12),
        FilledButton(onPressed: _toggle, child: Text(_playing? 'Pause':'Play')),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: ()=> setState(()=> _pts = 0), child: const Text('Seek 0')),
      ])),
    );
  }
}
