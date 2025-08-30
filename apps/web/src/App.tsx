import React from 'react'
import { VideoPlayer } from './components/VideoPlayer'
import view from './sample/view_sample.json'

export default function App(){
  return (
    <div style={{fontFamily:'system-ui', padding:16}}>
      <h1>Fokis Web Player Skeleton</h1>
      <p>ローカル video 要素を使った View 適用の最小デモ。</p>
      <VideoPlayer src="/sample/sample.mp4" view={view as any} />
    </div>
  )
}
