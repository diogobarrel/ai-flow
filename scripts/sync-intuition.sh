#!/usr/bin/env bash
# REL Sync — Recursive Expert Learning data pipeline
# Harvests Claude/Gemini session logs, curates the dataset, optionally triggers training.
#
# Usage:
#   ./scripts/sync-intuition.sh            # harvest + filter only
#   ./scripts/sync-intuition.sh --train    # harvest + filter + fine-tune

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/src"
DATA="$REPO_ROOT/data"

# Claude session logs default to ~/.claude/projects/<hash>/*.jsonl on Linux/WSL
CLAUDE_PROJECTS_DIR="${CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}"
GEMINI_TMP_DIR="${GEMINI_TMP_DIR:-$HOME/.gemini/tmp}"

DO_TRAIN=false
if [[ "${1:-}" == "--train" ]]; then
  DO_TRAIN=true
fi

echo "=== REL Sync — $(date '+%Y-%m-%d %H:%M') ==="
echo "Repo: $REPO_ROOT"
echo ""

# --- Phase A: Harvest Claude sessions ---
echo "▸ Harvesting Claude sessions from $CLAUDE_PROJECTS_DIR ..."
CLAUDE_PROJECTS_DIR="$CLAUDE_PROJECTS_DIR" python3 "$SRC/fine_tuning/claude_extractor.py" || true

# --- Phase B: Format Gemini sessions ---
echo "▸ Formatting Gemini sessions from $GEMINI_TMP_DIR ..."
GEMINI_TMP_DIR="$GEMINI_TMP_DIR" python3 "$SRC/fine_tuning/log_formatter.py" || true

# --- Phase C: Merge available data files ---
echo "▸ Merging datasets ..."
python3 "$SRC/fine_tuning/merge_data.py" || true

# --- Phase D: Filter / curate ---
echo "▸ Filtering dataset to system-agent scope ..."
python3 "$SRC/fine_tuning/filter_dataset.py"

# --- Summary ---
FILTERED="$DATA/training_data_filtered.jsonl"
if [[ -f "$FILTERED" ]]; then
  COUNT=$(wc -l < "$FILTERED")
  echo ""
  echo "✅ Dataset ready: $COUNT samples in $FILTERED"
else
  echo "⚠️  Filtered dataset not found at $FILTERED"
fi

# --- Phase E: Train (opt-in) ---
if [[ "$DO_TRAIN" == true ]]; then
  echo ""
  echo "▸ Starting fine-tuning (this will take a while on GPU)..."
  python3 "$SRC/fine_tuning/train.py"
  echo "✅ Training complete. Update Ollama with: ollama create flow-orchestrator -f models/orchestrator.Modelfile"
else
  echo ""
  echo "Tip: run with --train to also trigger fine-tuning."
fi
