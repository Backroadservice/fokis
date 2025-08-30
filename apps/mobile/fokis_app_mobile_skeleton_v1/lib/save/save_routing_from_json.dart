import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

enum UiAction { toastSaved, goConflict, showLimitDialog, showSchemaDialog, showRetrySnackBar }

class SaveRoutingConfig {
  final Map<int, UiAction> routes; final Map<int, String> messages;
  SaveRoutingConfig(this.routes, this.messages);
  UiAction actionFor(int status){ if(routes.containsKey(status)) return routes[status]!; if(status>=500 && routes.containsKey(500)) return routes[500]!; return UiAction.showRetrySnackBar; }
  String messageFor(int status){ if(messages.containsKey(status)) return messages[status]!; if(status>=500 && messages.containsKey(500)) return messages[500]!; return '再送します'; }
  static UiAction _parseAction(String s){ switch(s){ case 'toastSaved': return UiAction.toastSaved; case 'goConflict': return UiAction.goConflict; case 'showLimitDialog': return UiAction.showLimitDialog; case 'showSchemaDialog': return UiAction.showSchemaDialog; default: return UiAction.showRetrySnackBar; } }
  static Future<SaveRoutingConfig> loadFromAsset(String path) async {
    final j = jsonDecode(await rootBundle.loadString(path)) as Map<String,dynamic>;
    final r=<int,UiAction>{}; final m=<int,String>{};
    (j['routes'] as Map).forEach((k,v){ if(k=='5xx') r[500]=_parseAction(v); else r[int.parse(k)]=_parseAction(v); });
    (j['messages'] as Map).forEach((k,v){ if(k=='5xx') m[500]=v; else m[int.parse(k)]=v; });
    return SaveRoutingConfig(r,m);
  }
}
