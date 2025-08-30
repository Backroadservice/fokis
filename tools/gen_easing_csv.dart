import 'dart:io';
import '../lib/core/interpolator.dart';

void main(){
  final points = [0.0, 0.25, 0.5, 0.75, 1.0];
  final rows = <String>[];
  rows.add('case_id,easing,t_norm,expected_value,epsilon,notes');
  final cases = {
    'LINEAR': Easing.linear,
    'EASE_IN': Easing.easeIn,
    'EASE_OUT': Easing.easeOut,
    'EASE_IN_OUT': Easing.easeInOut,
  };
  cases.forEach((name, easing){
    for (final t in points){
      final y = Interpolator.sample(easing, t);
      rows.add('EZ-$name-${(t*100).toStringAsFixed(0)},$name,${t.toStringAsFixed(2)},${y.toStringAsFixed(6)},1e-6,gen');
    }
  });
  stdout.writeln(rows.join('\n'));
}
