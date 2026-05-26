# Recursive Expert Learning (REL) Architecture

## 1. Vision
To create a "digital twin" local model that learns the user's specific development patterns, system administration style, and PC environment by harvesting expert-level interactions from cloud LLMs (Gemini/Claude).

## 2. Data Pipeline
The loop consists of four distinct stages:

### Phase A: Harvesting (The "Expert" Trace)
- **Gemini CLI:** Extract pairs from `.gemini/tmp/*/chats/*.jsonl`
- **Claude Code:** Extract pairs from `.claude/projects/*/*.jsonl`
- **Manual "Gold" Samples:** Specifically curated tasks where the user provides a perfect solution.

### Phase B: Curation (The "Intuition" Filter)
- **Scope Enforcement:** Filter out out-of-scope tasks (e.g., frontend web dev) to keep the model specialized as a "Windows System Agent."
- **De-duplication:** Ensure the model isn't over-trained on simple "Hello" messages.
- **Normalization:** Format into Alpaca/SFT format (`### Instruction` / `### Response`).

### Phase C: Baking (The "Brain" Upgrade)
- **Fine-tuning:** Use Unsloth (4-bit QLoRA) on local GPU to inject harvested intuition into model weights.
- **Quantization:** Export to GGUF format for high-speed local inference in Ollama.

### Phase D: Validation (The "Reflection" Loop)
- **Live Test:** Run the new model on previous "failure" tasks.
- **Correction:** If the model still fails, it becomes a "priority 1" training case for the next cycle.

## 3. Tooling (Implemented)
- `src/fine_tuning/claude_extractor.py`: Multi-project log harvester.
- `src/fine_tuning/log_formatter.py`: Gemini CLI log harvester.
- `src/fine_tuning/filter_dataset.py`: System Agent scope enforcer.
- `src/fine_tuning/train.py`: GPU-accelerated trainer and GGUF exporter.

## 4. Operational Routine
1. **Usage:** Work normally with Gemini/Claude.
2. **Sync:** Run `scripts/sync-intuition.ps1` (to be created) every Friday.
3. **Evolve:** Restart Ollama with the newly fine-tuned `flow-orchestrator` model.
