#!/usr/bin/env bash
set -euo pipefail

DATE="${DATE:-$(date +%Y-%m-%d)}"

git switch -c "feat/${DATE}-evolution"

mkdir -p "bioscale-evidence/${DATE}" "telemetry/${DATE}" "research"

cargo build -p bioscale-upgrade-macros

cargo build -p cyberswarm-neurostack -p cybernano-guard -p bioscale-metrics

cargo fmt
cargo clippy --all-targets --all-features -- -D warnings

cargo test --all

kani --enable-unstable --harness check_evolution_window_safety || true

cargo build --release \
    -p cyberswarm-neurostack \
    -p cybernano-guard \
    -p bioscale-upgrade-store

cargo run -p bioscale-evolution-cli -- --date "${DATE}"

git add \
  "bioscale-evidence/${DATE}" \
  "telemetry/${DATE}" \
  "research/${DATE}-manifest.json" \
  crates

git commit -m "daily evolution window ${DATE}"
