# Fokis Sprint v1 — Start Pack

このパックは **今は保存だけ** でOK。実際に適用する日は以下の順で進めれば一気に走れます。

## 0) 前提
- ブランチ: `p1/sprint-v1`
- Dart 3.x / Flutter 3.x（Flutterはデモ時のみ）
- 事前に `fokis_all_packs_master_YYYYMMDD.zip` を保存済み

## 1) 初期化（自動化スクリプトあり）
```bash
bash scripts/init_sprint_repo.sh packs/fokis_all_packs_master_YYYYMMDD.zip
```

## 2) 検証フロー
1. `dart pub get && dart test`（契約/単体/E2E 緑）
2. CLI: 
   ```bash
   dart tools/validate_view.dart 1048576 120
   dart tools/gen_easing_csv.dart > testdata/easing_expected_values_gen.csv
   dart tools/e2e_sim.dart
   ```
3. Flutter デモ（任意）:
   - 競合 Resolver: `examples/conflict_demo_flutter` または `..._plus` を `flutter run`
   - Save Routing JSON デモ: `examples/save_routing_demo_flutter` を `flutter run`

## 3) ボード/課題の種
- `project_board_seed.csv` を GitHub Projects などへインポート
- `dod_to_issues/` のスクリプトで DoD を Issue 化（`gh` CLI 必要）

## 4) 定数・フラグ（暫定）
- `SYNC_HYSTERESIS_MS=33` / `MAX_EVENTS=5000` / `MAX_VIEW_SIZE_COMPRESSED=8MB`
- `conflict_resolver_enabled=false`（Canary有効化で true）

## 5) 収束のDoD（抜粋）
- 再生 Δ誤差 P95 ≤ 25ms（境界/低FPS/バッファ復帰）
- 200/409/413/422/408/5xxの UI 分岐が定数どおり
- 409→Diff→採否→単一コミットのデモ経路が成功
- KPI: save_success_rate / conflict_rate / sync_delta_p95 が取得可能
