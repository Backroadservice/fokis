import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import '../lib/core/interpolator.dart';

void main(){
  test('CSV expected values', () async {
    final csv = await File('test/testdata/easing_expected_values.csv').readAsString();
    final lines = const LineSplitter().convert(csv);
    for (int i=1;i<lines.length;i++){
      final cols = lines[i].split(',');
      final easing = _parse(cols[1]);
      final t = double.parse(cols[2]);
      final expected = double.parse(cols[3]);
      final eps = double.parse(cols[4].replaceAll('e-6','0.000001'));
      final y = Interpolator.sample(easing, t);
      expect((y-expected).abs() <= eps, isTrue, reason: 'line $i: got=$y exp=$expected');
    }
  });
}

Easing _parse(String name){
  switch(name){
    case 'EASE_IN': return Easing.easeIn;
    case 'EASE_OUT': return Easing.easeOut;
    case 'EASE_IN_OUT': return Easing.easeInOut;
    default: return Easing.linear;
  }
}

