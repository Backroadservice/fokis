import 'package:flutter/material.dart';
import 'save_routing_from_json.dart';

class SaveFlowDemoScreen extends StatefulWidget {
  const SaveFlowDemoScreen({super.key});
  @override State<SaveFlowDemoScreen> createState()=>_S();
}
class _S extends State<SaveFlowDemoScreen>{
  SaveRoutingConfig? cfg;
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async { cfg = await SaveRoutingConfig.loadFromAsset('assets/save_routing_map.json'); setState((){}); }
  void _handle(int status){
    if(cfg==null) return;
    final act = cfg!.actionFor(status);
    final msg = cfg!.messageFor(status);
    switch(act){
      case UiAction.toastSaved: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))); break;
      case UiAction.goConflict: ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('→ 競合解決へ'))); break;
      case UiAction.showLimitDialog: showDialog(context: context, builder:(_)=>AlertDialog(title: const Text('上限超過'), content: Text(msg))); break;
      case UiAction.showSchemaDialog: showDialog(context: context, builder:(_)=>AlertDialog(title: const Text('不整合'), content: Text(msg))); break;
      case UiAction.showRetrySnackBar: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))); break;
    }
  }
  @override Widget build(BuildContext c){
    return Scaffold(
      appBar: AppBar(title: const Text('保存UI分岐（JSON外出し）')),
      body: Center(child: Wrap(spacing: 12, children: [
        FilledButton(onPressed: ()=>_handle(200), child: const Text('200')),
        FilledButton.tonal(onPressed: ()=>_handle(409), child: const Text('409')),
        OutlinedButton(onPressed: ()=>_handle(413), child: const Text('413')),
        OutlinedButton(onPressed: ()=>_handle(422), child: const Text('422')),
        OutlinedButton(onPressed: ()=>_handle(408), child: const Text('408')),
        OutlinedButton(onPressed: ()=>_handle(503), child: const Text('5xx')),
      ])),
    );
  }
}
