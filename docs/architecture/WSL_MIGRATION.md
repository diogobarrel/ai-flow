# WSL2 Migration Guide: Local AI Dev Orchestrator

This guide explains how to migrate the project and the "Recursive Expert Learning" (REL) loop from native Windows to WSL2.

## 1. Prerequisites (Inside WSL2)
- Ubuntu 22.04 or 24.04 (recommended)
- Python 3.10+
- Node.js (for Hermes Agent)
- NVIDIA Container Toolkit (for GPU access)

## 2. Setup Steps

### A. Clone and Environment
```bash
git clone <your-repo-url> ai-flow
cd ai-flow
git checkout wsl-migration
python3 -m venv .venv-wsl
source .venv-wsl/bin/activate
pip install -r requirements-rag.txt
```

### B. Install Unsloth (Linux is much easier!)
```bash
pip install "unsloth[colab-new] @ git+https://github.com/unslothai/unsloth.git"
# Unsloth on Linux usually works out of the box with the correct CUDA drivers
```

### C. Install Hermes Agent
```bash
# Follow instructions at https://github.com/nousresearch/hermes-agent
# Hermes will act as the 'Expert Trainer' in WSL2
```

## 3. The Hybrid Workflow
To continue the **Windows System Agent** mission from WSL2:

1. **Harvesting:** Run `python3 src/fine_tuning/claude_extractor.py` and `python3 src/fine_tuning/log_formatter.py`. These scripts are path-aware and may need adjustment to point to your Windows AppData via `/mnt/c/Users/santo/AppData/...`.
2. **Execution:** Configure Hermes Agent to use the `SSH` backend to talk back to your Windows 11 host, or use `/mnt/c/` for direct file operations.
3. **Training:** Run `python3 src/fine_tuning/train.py` inside WSL. It will be faster and more stable.

## 4. Path Mapping
- Windows: `C:\Users\santo\.gemini` -> WSL: `/mnt/c/Users/santo/.gemini`
- Windows: `C:\Users\santo\.claude` -> WSL: `/mnt/c/Users/santo/.claude`
- Windows: `C:\Users\santo\Dev`     -> WSL: `/mnt/c/Users/santo/Dev`

---
*Generated during the 'Recursive Learning' setup on 2026-05-25*
