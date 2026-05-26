# Sync Intuitive Master Script
# This script automates the entire learning loop pipeline

Write-Host "🚀 Starting Recursive Intuition Sync..." -ForegroundColor Cyan

# 1. Harvest from Claude
Write-Host "--- Harvesting Claude Expert Logs ---"
python src/fine_tuning/claude_extractor.py

# 2. Harvest from Gemini
Write-Host "--- Harvesting Gemini Expert Logs ---"
python src/fine_tuning/log_formatter.py

# 3. Merge and Filter
Write-Host "--- Curating Dataset (Windows Agent Scope) ---"
python src/fine_tuning/merge_data.py
python src/fine_tuning/filter_dataset.py

Write-Host "✅ Dataset Ready at data/training_data_filtered.jsonl" -ForegroundColor Green
Write-Host "Next step: Run training script using .venv-train"
