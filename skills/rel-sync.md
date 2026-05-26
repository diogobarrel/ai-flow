---
name: rel-sync
description: Run the Recursive Expert Learning pipeline to harvest Claude/Gemini session logs, curate a fine-tuning dataset, and optionally trigger model training.
version: 1.0.0
metadata:
  hermes:
    tags: [learning, fine-tuning, rel, ai-flow]
    category: workflow
---

# REL Sync — Recursive Expert Learning

Run this skill to advance the learning loop: harvest expert interactions from cloud LLMs, curate them, and (optionally) fine-tune the local orchestrator model.

## When to Use

- Weekly maintenance to keep `flow-orchestrator` current
- After an unusually productive Claude/Gemini session worth capturing
- When the local model is giving noticeably worse answers than a few weeks ago

## Procedure

### Step 1 — Confirm environment

```bash
ls ~/dev/ai-flow/data/
```

Verify the `data/` directory exists and contains any existing `.jsonl` files.

### Step 2 — Run the sync script

```bash
cd ~/dev/ai-flow
bash scripts/sync-intuition.sh
```

This runs: harvest Claude logs → format Gemini logs → merge → filter.
It prints a summary with the final sample count.

### Step 3 — Review the output

```bash
head -3 data/training_data_filtered.jsonl | python3 -m json.tool
```

Spot-check a few samples. Look for: correct instruction/response structure, no leaked secrets, on-topic system-agent tasks.

### Step 4 — (Optional) Fine-tune

Only do this when you have 200+ new samples and time for a ~30-minute GPU run:

```bash
bash scripts/sync-intuition.sh --train
```

Then reload in Ollama:

```bash
ollama create flow-orchestrator -f ~/dev/ai-flow/models/orchestrator.Modelfile
```

### Step 5 — Schedule (set-and-forget)

To run this automatically every Friday at 21:00, tell Hermes:

> "Schedule `/rel-sync` every Friday at 9pm"

Hermes will create a cron entry. Verify with `hermes cron list`.

## Pitfalls

- If `claude_extractor.py` finds 0 logs, check that `CLAUDE_PROJECTS_DIR` points to `~/.claude/projects`
- If `filter_dataset.py` discards too many samples, the keyword lists in `src/fine_tuning/filter_dataset.py` may need updating
- Training requires the `unsloth` package and a CUDA GPU — do not run on CPU

## Verification

After the sync, `data/training_data_filtered.jsonl` should exist and have > 0 lines:

```bash
wc -l data/training_data_filtered.jsonl
```
