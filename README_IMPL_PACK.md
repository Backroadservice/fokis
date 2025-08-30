# Fokis Sprint v1 Implementation Pack 01 — Core/Sync/Scheduler/Tests/CLI (2025-08-17)

このパックは P1（再生・エディタ・保存/競合）実装の **最初の適用差分** です。
- Core: Interpolator / Scheduler / SyncController / EventStore
- Player: Fake facade（テスト用）
- Tests: R-001..R-004 + Easing 期待値
- Save Routing: JSONベースの定数化（テスト用コピー）
- Telemetry: 最小ロガー
- CLI: validate_view / gen_easing_csv
- Config: app_config.json（flag/閾値）

## 適用順
1) リポジトリ直下に展開
2) `dart pub get`
3) `dart test` を実行（最初は一部 pending 可）

## 配置
- lib/core/...
- lib/player/...
- lib/save/...
- test/...
- tools/...
- config/app_config.json
