import { sample, Easing } from './Interpolator';

type Key = { offset_ms:number, value:number, easing:Easing };
type Channel = { channel_id:string, keys: Key[] };
type Action = { action_type:string, channels: Channel[] };
type Event = { event_id:string, type:string, duration_ms:number, actions: Action[] };
type TimelineEntry = { pts_ms:number, event_id:string };
export type View = { meta:any, events: Record<string, Event>, timeline: TimelineEntry[] };

export type AppliedFrame = { panX:number, panY:number, scale:number, angle:number, alpha:number };

export function evaluate(view:View, pts:number):AppliedFrame{
  const ev = resolveEvent(view, pts);
  if(!ev) return {panX:0, panY:0, scale:1, angle:0, alpha:1};
  const local = localMs(view, ev, pts);
  return applyEvent(ev, local);
}

function resolveEvent(view:View, pts:number):Event|undefined{
  let chosen: {start:number, e:Event}|undefined;
  for(const t of view.timeline){
    const e = view.events[t.event_id];
    const start = t.pts_ms;
    const end = start + e.duration_ms;
    if (pts >= start && pts < end){
      if (!chosen || start > chosen.start) chosen = {start, e};
    }
  }
  return chosen?.e;
}

function localMs(view:View, ev:Event, pts:number):number{
  let start=0;
  for(const t of view.timeline){
    if (t.event_id === ev.event_id){ start = t.pts_ms; break; }
  }
  return Math.max(0, pts - start);
}

function lerp(a:number,b:number,t:number){ return a + (b-a)*t; }

function applyEvent(ev:Event, localMs:number):AppliedFrame{
  let panX=0, panY=0, scale=1, angle=0, alpha=1;
  for(const act of ev.actions){
    for(const ch of act.channels){
      const k = ch.keys;
      if (k.length===0) continue;
      const tnorm = Math.min(1, Math.max(0, localMs / Math.max(1, ev.duration_ms)));
      // find segment
      let left = k[0], right = k[k.length-1];
      for(let i=1;i<k.length;i++){ if (localMs < k[i].offset_ms){ right = k[i]; left = k[i-1]; break; } }
      const segDur = Math.max(1, right.offset_ms - left.offset_ms);
      const segT = Math.min(1, Math.max(0, (localMs - left.offset_ms) / segDur));
      const eased = sample(left.easing as Easing, segT);
      const v = lerp(left.value, right.value, eased);
      switch(ch.channel_id){
        case 'CH_X': panX = v; break;
        case 'CH_Y': panY = v; break;
        case 'CH_SCALE': scale = v; break;
        case 'CH_ANGLE': angle = v; break;
        case 'CH_ALPHA': alpha = v; break;
      }
    }
  }
  return {panX, panY, scale, angle, alpha};
}
