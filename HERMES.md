# ai-flow — Hermes Context

This is **ai-flow**: a workflow system for AI-assisted development. It is not a framework.
It defines conventions, routing rules, scripts, and a local learning loop.

## What's here

| Path | Purpose |
|---|---|
| `WORKFLOW.md` | Prescriptive routing rules (task → tool in 30s) |
| `src/rag_pipeline/` | LlamaIndex + ChromaDB codebase indexer and query interface |
| `src/fine_tuning/` | Unsloth/QLoRA pipeline — harvest Claude/Gemini sessions → fine-tune local model |
| `src/mcp_rag_server.py` | MCP stdio server exposing RAG tools (you are connected to this) |
| `scripts/sync-intuition.sh` | REL automation — runs harvest → filter pipeline |
| `skills/rel-sync.md` | `/rel-sync` skill — invoke to run the learning loop |
| `config/` | Config templates for Hermes, Claude Code, Gemini CLI |
| `agents/` | Agent definitions and routing rules |
| `prompts/` | System prompts and 3-file session templates (ARCHITECTURE/PROMPT/STATUS) |
| `open-interpreter/dev.py` | Legacy local agent (superseded by Hermes, kept as reference) |

## MCP Tools Available

- `search_dev_codebase(query)` — semantic search over ~/dev codebase index
- `reindex_dev_codebase(source_dir?)` — rebuild the ChromaDB index

Always call `search_dev_codebase` before answering questions about existing projects.

## Learning Loop

Run `/rel-sync` to harvest Claude and Gemini session logs, filter them, and prepare a fine-tuning dataset.
The trained model (`flow-orchestrator` via Ollama) can then replace the base model for routing tasks.

## Key Principle

"**Sem framework próprio**" — if this repo starts feeling like a platform, stop and read WORKFLOW.md.
