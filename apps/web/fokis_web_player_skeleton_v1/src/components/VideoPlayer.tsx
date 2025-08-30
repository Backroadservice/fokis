import React, { useEffect, useRef, useState } from 'react'
import { View, evaluate } from '../core/ViewApplier'

type Props = { src: string, view: View }

export const VideoPlayer: React.FC<Props> = ({src, view}) => {
  const vref = useRef<HTMLVideoElement>(null)
  const [pts, setPts] = useState(0)
  const [frame, setFrame] = useState({panX:0, panY:0, scale:1, angle:0, alpha:1})

  useEffect(()=>{
    let raf = 0
    const loop = () => {
      raf = requestAnimationFrame(loop)
      const v = vref.current
      if (!v) return
      const nowMs = (v.currentTime || 0) * 1000
      setPts(nowMs)
      const f = evaluate(view, nowMs)
      setFrame(f)
    }
    raf = requestAnimationFrame(loop)
    return () => cancelAnimationFrame(raf)
  }, [view])

  const style: React.CSSProperties = {
    transform: `translate(${frame.panX}px, ${frame.panY}px) scale(${frame.scale}) rotate(${frame.angle}deg)`,
    transformOrigin: 'center center',
    transition: 'transform 16ms linear',
    opacity: frame.alpha,
    willChange: 'transform, opacity'
  }

  return (
    <div style={{display:'grid', gridTemplateColumns:'1fr 320px', gap:16}}>
      <div style={{position:'relative', overflow:'hidden', background:'#111', aspectRatio:'16/9'}}>
        <video ref={vref} src={src} controls style={{width:'100%', height:'100%', objectFit:'contain'}} />
        <div style={{position:'absolute', left:0, top:0, right:0, bottom:0, pointerEvents:'none'}}>
          {/* overlay target */}
          <div style={{position:'absolute', left:'50%', top:'50%', transform:'translate(-50%,-50%)', ...style}}>
            <div style={{width:200, height:120, border:'2px solid #0ff', boxShadow:'0 0 8px #0ff', background:'transparent'}}/>
          </div>
        </div>
      </div>
      <aside>
        <h3>Debug</h3>
        <div>PTS: {pts.toFixed(0)} ms</div>
        <div>pan=({frame.panX.toFixed(1)}, {frame.panY.toFixed(1)})</div>
        <div>scale={frame.scale.toFixed(2)}</div>
        <div>angle={frame.angle.toFixed(1)}</div>
        <div>alpha={frame.alpha.toFixed(2)}</div>
        <p style={{fontSize:12, color:'#666'}}>※ overlay はデモ用（後で Canvas/WebGL に差し替え可能）</p>
      </aside>
    </div>
  )
}
