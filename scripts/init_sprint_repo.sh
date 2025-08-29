    #!/usr/bin/env bash
    set -euo pipefail
    if [ $# -lt 1 ]; then
      echo "Usage: $0 <master_zip_path>"
      exit 64
    fi
    MASTER_ZIP="$1"
    echo "[Init] Switch to branch p1/sprint-v1 (create if missing)"
    git checkout -B p1/sprint-v1 || true

    echo "[Init] Unzip master packs"
    unzip -o "$MASTER_ZIP" -d .

    echo "[Init] Apply packs in recommended order"
    while IFS= read -r pack; do
      echo "  - Applying $pack"
      unzip -o "packs/$pack" -d .
    done <<'LIST'
fokis_sprint_exec_bootstrap.zip
fokis_sprint_pack_ci.zip
fokis_sprint_pack_contract_tests.zip
fokis_sprint_pack_telemetry.zip
fokis_sprint_pack_conflict_demo.zip
fokis_sprint_pack_e2e.zip
fokis_sprint_pack_ab_metrics.zip
fokis_sprint_pack_schema_validator.zip
fokis_sprint_pack_save_routing_json.zip
fokis_sprint_pack_conflict_templates.zip
fokis_sprint_pack_flutter_runner_root.zip
LIST

    echo "[Init] Dart deps & tests"
    dart pub get
    dart test || true  # allow red initially

    echo "[Init] Done. Check 'README_MASTER.txt' for details."
