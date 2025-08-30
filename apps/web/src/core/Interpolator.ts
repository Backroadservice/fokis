export type Easing = 'LINEAR'|'EASE_IN'|'EASE_OUT'|'EASE_IN_OUT';

export function sample(easing:Easing, t:number):number{
  t = Math.min(1, Math.max(0, t));
  switch(easing){
    case 'LINEAR': return t;
    case 'EASE_IN': return cubicBezierY(t, 0.42, 0.0, 1.0, 1.0);
    case 'EASE_OUT': return cubicBezierY(t, 0.0, 0.0, 0.58, 1.0);
    case 'EASE_IN_OUT': return cubicBezierY(t, 0.42, 0.0, 0.58, 1.0);
  }
}

function cubicBezierY(t:number, x1:number, y1:number, x2:number, y2:number):number{
  let lo=0, hi=1;
  for(let i=0;i<40;i++){
    const mid=(lo+hi)/2;
    const x=bezierX(mid, x1, x2);
    if (x < t) lo = mid; else hi = mid;
  }
  const s=(lo+hi)/2;
  return bezierY(s, y1, y2);
}
function bezierX(s:number, x1:number, x2:number){ const inv=1-s; return 3*inv*inv*s*x1 + 3*inv*s*s*x2 + s*s*s; }
function bezierY(s:number, y1:number, y2:number){ const inv=1-s; return 3*inv*inv*s*y1 + 3*inv*s*s*y2 + s*s*s; }
