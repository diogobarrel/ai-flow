# ai-dev-flow

Como eu desenvolvo código com IA usando o ferramental que já tenho — Claude Code, Gemini CLI, Ollama local, Pi/OpenRouter — de forma prescriptiva e com custo controlado.

**Não é um framework.** É um **fluxo de trabalho**: convenções, receitas e alguns scripts curtos. Não há código TypeScript pra instalar, nem CLI pra construir.

---

## Comece aqui

📄 **[`WORKFLOW.md`](./WORKFLOW.md)** — o pager prescriptivo. Tarefa → ferramenta em 30 segundos. **Leia primeiro.**

📁 **[`playbooks/`](./playbooks/)** — receitas markdown para tarefas comuns (new-feature, bug-investigation, refactor-module, code-review)

📁 **[`local-helpers/`](./local-helpers/)** — scripts bash + PowerShell que chamam Ollama local para tarefas mecânicas (commit msg, diff summary, error explanation, code review)

📁 **[`prompts/`](./prompts/)** — system prompts e templates dos 3-arquivos (ARCHITECTURE/PROMPT/STATUS) usados em projetos derivados

📄 **[`cost.log`](./cost.log)** — log manual de uso pago (Pi/OpenRouter)

---

## Setup rápido

```bash
# CLIs
npm install -g @anthropic-ai/claude-code @google/gemini-cli
claude && gemini auth login

# Ollama + modelos
ollama pull qwen2.5-coder:7b qwen2.5-coder:14b llama3.2:3b gemma3:12b hermes3:8b

# Hermes Agent (orquestrador local com learning loop)
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
source ~/.bashrc
cp config/hermes-config-template.yaml ~/.hermes/config.yaml
cp config/hermes-soul-template.md ~/.hermes/SOUL.md
cp skills/rel-sync.md ~/.hermes/skills/rel-sync.md

# Local helpers no PATH
echo 'export PATH="$HOME/dev/ai-flow/local-helpers:$PATH"' >> ~/.bashrc
chmod +x ~/dev/ai-flow/local-helpers/*.sh
```

Detalhes completos em [`WORKFLOW.md` §Setup mínimo](./WORKFLOW.md#setup-m%C3%ADnimo).

---

## O que tem onde

| O quê | Onde |
|---|---|
| Decisão "tarefa → ferramenta" | [`WORKFLOW.md`](./WORKFLOW.md) |
| Contexto do Hermes Agent (auto-carregado) | [`HERMES.md`](./HERMES.md) |
| Config e SOUL templates para Hermes | [`config/hermes-config-template.yaml`](./config/hermes-config-template.yaml), [`config/hermes-soul-template.md`](./config/hermes-soul-template.md) |
| Skill REL para Hermes | [`skills/rel-sync.md`](./skills/rel-sync.md) |
| MCP RAG server (Hermes tool) | [`src/mcp_rag_server.py`](./src/mcp_rag_server.py) |
| Pipeline REL (harvest → filter → train) | [`scripts/sync-intuition.sh`](./scripts/sync-intuition.sh) |
| Receitas reutilizáveis | [`playbooks/`](./playbooks/) |
| Scripts Ollama | [`local-helpers/`](./local-helpers/) |
| System prompts | [`prompts/`](./prompts/) |
| Configs das CLIs | [`config/`](./config/) |
| Setup scripts | [`scripts/`](./scripts/) |
| Definições conceituais de agentes | [`agents/`](./agents/) |
| Log de custo manual | [`cost.log`](./cost.log) |
| Exploração arquitetural anterior | [`docs/architecture/`](./docs/architecture/) — ver STATUS interno |
| Iterações antigas consolidadas | [`docs/legacy/`](./docs/legacy/) |

---

## Princípios em uma linha cada

- **Local-first** — Ollama na GPU para tudo que é mecânico e recorrente
- **Linux-Native** — Otimizado para workflows nativos em Linux
- **Assinatura antes de crédito** — Claude/Gemini antes de Pi/Kimi
- **Determinístico antes de IA** — sed/jq/regex antes de modelo
- **Uma fase por sessão** — STATUS.md como ponte entre sessões
- **Playbook após o terceiro X** — só vira receita quando já fiz 3 vezes
- **Sem framework próprio** — se virar plataforma, parar e ler [`docs/architecture/STATUS.md`](./docs/architecture/STATUS.md)

---

## Dependências

- [Claude Code CLI](https://docs.claude.com/en/docs/agents-and-tools/claude-code/overview)
- [Gemini CLI](https://github.com/google-gemini/gemini-cli)
- [Ollama](https://ollama.com)
- Node.js 18+, Git, GPU NVIDIA pra Ollama (testado em RTX 5070 Ti / 16GB VRAM)

---

## Licença

MIT
