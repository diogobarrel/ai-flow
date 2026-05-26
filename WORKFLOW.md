# ai-flow — Workflow

Como eu desenvolvo código com IA usando o ferramental que já tenho, de forma eficiente e com custo controlado. Documento prescriptivo. Atualizar sempre que uma regra mudar na prática.

**Última revisão:** 2026-05-25

---

## Ferramental (o que eu tenho)

| Tool | Modelo | Custo | Onde |
|---|---|---|---|
| **Claude Code CLI** | Sonnet 4.6 (default), Haiku 4.5 | Assinatura PRO (sem custo/token) | PC |
| **Gemini CLI** | Gemini 2.5 Pro (default), 2.5 Flash | Assinatura PRO (sem custo/token) | PC |
| **Hermes Agent** | hermes3:8b via Ollama (local orchestrator) | Grátis (GPU local) | PC, RTX 5070 Ti, 16GB VRAM |
| **Ollama** | qwen2.5-coder:7b, qwen2.5-coder:14b, gemma3:12b, llama3.2:3b | Grátis (GPU local) | PC, RTX 5070 Ti, 16GB VRAM |
| **Pi terminal + OpenRouter** | Kimi-2.6 (k2-5) | **Créditos** ($) | Pi |

> Regra de ouro: **Pi/OpenRouter é o único caminho que custa dinheiro de verdade.** Tudo mais é assinatura ou local. Use Pi como fallback de quota, não como primeira opção.

---

## A regra: tarefa → ferramenta em 30 segundos

Toda tarefa cai numa das 6 categorias abaixo. Cada categoria tem **uma** ferramenta default. Sem decisão no momento — a decisão já foi tomada aqui.

### 1. Tarefa principal de código

Implementação, arquitetura, debugging, refatoração multi-arquivo, spec de feature, decisão técnica não trivial.

→ **Claude Code CLI (Sonnet)** — `claude` no terminal do projeto.

Override: se a tarefa exige contexto >100k tokens, vai pra categoria 2.

### 2. Análise de codebase grande / pesquisa web / multimodal

Contexto >100k tokens (analisar repo inteiro, ler docs gigantes), pesquisa que exige dados atualizados via search grounding, análise de imagem/PDF/screenshot.

→ **Gemini CLI (2.5 Pro)** — `gemini` no terminal.

Para pesquisa rápida com search grounding e custo zero de raciocínio, use Flash em vez de Pro.

### 3. Tarefa mecânica recorrente

Coisas que faço várias vezes por semana e não exigem raciocínio profundo: gerar commit message a partir do diff, resumir um diff em 3 bullets, explicar um erro de stderr, classificar uma issue, draft de docstring.

→ **Local helper (Ollama)** — `flow-<comando>` no terminal. Lista em [`local-helpers/`](./local-helpers/).
→ **Hermes Agent** — `hermes` no terminal para tarefas que se beneficiam de memória cross-session, execução de código, ou busca no codebase via RAG.

Critério de promoção: se uma tarefa entra nessa categoria mas eu não tenho helper pra ela ainda, e fiz manualmente 3x → criar helper. Se exige contexto de sessões anteriores → usar Hermes.

### 4. Code review do meu próprio diff

Antes de commit/push, passar o diff por um revisor.

→ **Local helper** `flow-review-diff` (Ollama qwen2.5-coder:14b) por padrão. Se o diff é grande (>500 linhas) ou toca arquitetura, escala pra Claude Code Sonnet via playbook [`code-review`](./playbooks/code-review.md).

### 5. Quota Claude esgotada

`claude` retornou "rate limited" ou quota mensal estourou.

→ Tenta **Gemini CLI** primeiro (também assinatura).
→ Se Gemini também esgotado, vai pro **Pi terminal (Kimi)**.
→ Nunca use Pi se Claude ou Gemini estão disponíveis.

### 6. Pura transformação determinística

Reformatar JSON, regex, renomear arquivos em lote, conversão de formato, busca de string.

→ **Shell tools nativos** (`jq`, `sed`, `rg`, `fd`, etc.). **Nada de IA**.

---

## Decisão visual (3 perguntas)

```
1. Preciso de raciocínio de código / decisão técnica?
   └─ SIM → Claude Code Sonnet (cat. 1)
   └─ NÃO → 2

2. É tarefa mecânica que eu faço várias vezes por semana?
   └─ SIM → tem helper local? → flow-<cmd>   (cat. 3)
                  → não tem? → criar e usar  (cat. 3)
   └─ NÃO → 3

3. Preciso de contexto grande / web / multimodal?
   └─ SIM → Gemini CLI                       (cat. 2)
   └─ NÃO → é transformação pura?
              └─ SIM → shell                  (cat. 6)
              └─ NÃO → volta pra Claude Code  (cat. 1)

(Em qualquer ponto, se quota Claude+Gemini esgotou → Pi/Kimi como fallback)
```

---

## Convenção de handoff entre sessões/tools

A ponte entre uma sessão e outra (ou entre Claude e Gemini, ou entre eu e o futuro-eu) são **três arquivos por projeto**, na raiz do projeto-alvo (não deste repo):

| Arquivo | Função | Quando edita |
|---|---|---|
| `ARCHITECTURE.md` | O quê e por quê — componentes, ADRs, stack, fases. Referência permanente. | No início e em decisões arquiteturais |
| `PROMPT.md` | Como executar — receita step-by-step, fases sequenciais com DoD | Quando o plano muda |
| `STATUS.md` | Estado atual — fase atual, blockers, próximos passos, decisões não planejadas | **Ao fim de toda sessão** |

Templates em [`prompts/templates/`](./prompts/templates/).

**Regra absoluta:** ao trocar de tool ou abrir nova sessão, sempre começo com:

```
Leia ARCHITECTURE.md, STATUS.md e PROMPT.md.
Fase atual: <X>. Tarefa: <descrição>.
Liste ambiguidades antes de implementar.
```

Nunca carrego contexto via histórico de chat. STATUS.md é a única fonte de verdade entre sessões.

---

## Local-first reflex (quando Ollama, sempre Ollama)

Antes de mandar qualquer coisa pra cloud, pergunto:

1. Isso é uma transformação de texto onde o "certo" é checável em git diff?
2. Isso é uma classificação binária ou de poucas categorias?
3. Isso é resumir/extrair de algo curto (<2k tokens)?
4. Eu faço isso várias vezes por semana?

Se sim pra qualquer uma → Ollama. Lista de helpers em [`local-helpers/`](./local-helpers/).

Modelos default:
- **Tarefa de código** → `qwen2.5-coder:7b` (rápido) ou `:14b` (qualidade)
- **Classificação/extração simples** → `llama3.2:3b` (super rápido, baixa VRAM)
- **Generation conversacional curta** → `gemma3:12b`

---

## Disciplina por sessão (regra de ouro contra contexto inchado)

- **Uma fase por sessão** — não tente fazer 2 fases na mesma sessão Claude. Encerra, atualiza STATUS.md, commit, próxima sessão.
- **Sessão >50k tokens ou >2h** = sinal de encerrar. Atualiza STATUS, commit, próxima sessão lê os artefatos.
- **Sempre listar ambiguidades antes de implementar.** O modelo não pergunta sozinho com a frequência ideal; eu peço explicitamente.

---

## Cost discipline (log manual)

Pi/Kimi é o único custo real. Mantenho [`cost.log`](./cost.log) anotando manualmente:

```
## YYYY-MM-DD
- HH:MM — Pi/Kimi — <projeto> — <task> — ~<tokens> tokens — ~$<X>
```

Revisão semanal de 30 segundos. Se algum dia eu virar dependente do Pi pra mais que fallback, repenso o flow.

---

## Playbooks (receitas para tarefas comuns)

Cada playbook é um arquivo markdown com: tool, prompt template copy-paste, output esperado, critério de encerramento. Lista atual:

- [`new-feature`](./playbooks/new-feature.md) — demanda vaga → spec → impl
- [`bug-investigation`](./playbooks/bug-investigation.md) — repro → hipótese → fix → regression test
- [`refactor-module`](./playbooks/refactor-module.md) — análise → plano → mudanças seguras
- [`code-review`](./playbooks/code-review.md) — review do próprio diff antes de PR

**Critério pra criar novo playbook:** já fiz a tarefa do mesmo jeito 3+ vezes → vira playbook.

---

## Quando ESCALAR de tool

| Sintoma | Ação |
|---|---|
| Ollama local não está acertando classificação simples → confio na qualidade? | Promove pra Claude Haiku (assinatura, baixo custo) |
| Claude Code travou em raciocínio circular | Encerra sessão, escreve hipótese em STATUS.md, abre nova sessão começando da hipótese |
| Claude Code não tem contexto suficiente do codebase | Pula pra Gemini CLI com o contexto inteiro |
| Quota Claude esgotada e tenho deadline | Pi/Kimi, anota em cost.log |
| Estou re-explicando a mesma coisa 3x em prompts diferentes | Vira playbook ou system prompt em [`prompts/`](./prompts/) |

---

## O que NÃO faço

- **Não uso IA pra transformação determinística** — sed/jq/regex resolvem
- **Não uso Pi/Kimi como default** — é fallback de quota, não primeira opção
- **Não misturo fases na mesma sessão** — uma fase, um commit, um STATUS update
- **Não carrego contexto via chat** — sempre via os 3 arquivos
- **Não construo framework pra esse fluxo** — o fluxo é processo + scripts pequenos. Se virar grande, paro e repenso.

---

## Setup mínimo

Primeira vez num PC novo:

```bash
# Claude Code
npm install -g @anthropic-ai/claude-code
claude   # login interativo

# Gemini CLI
npm install -g @google/gemini-cli
gemini auth login

# Ollama + modelos default
# (instalar Ollama do site oficial)
ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:14b
ollama pull llama3.2:3b
ollama pull gemma3:12b
ollama pull hermes3:8b  # modelo para o Hermes Agent

# Hermes Agent (orquestrador local com learning loop)
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
source ~/.bashrc

# Configurar Hermes para usar Ollama local
cp config/hermes-config-template.yaml ~/.hermes/config.yaml
cp config/hermes-soul-template.md ~/.hermes/SOUL.md
# (ajuste os caminhos em ~/.hermes/config.yaml se necessário)

# Instalar skill REL no Hermes
cp skills/rel-sync.md ~/.hermes/skills/rel-sync.md

# Local helpers — adicionar ao PATH
echo 'export PATH="$HOME/dev/ai-flow/local-helpers:$PATH"' >> ~/.bashrc
```

Pi terminal: configurado separadamente, fora deste repo.

## Learning Loop (Hermes + REL)

O Hermes Agent adiciona três primitivas de aprendizado que o Open Interpreter não tinha:

| Primitiva | Como usar |
|---|---|
| **Cross-session memory** | Automático — Hermes salva e recupera contexto entre sessões |
| **Skill auto-creation** | Automático após tarefas complexas (5+ tool calls) |
| **REL sync** | Manual: `/rel-sync` no Hermes, ou via `hermes cron` semanalmente |

Para agendar o REL sync semanal, diga ao Hermes: `"Schedule /rel-sync every Friday at 9pm"`.

---

## Onde estão as coisas

| O quê | Onde |
|---|---|
| Este pager (decisão por categoria) | `WORKFLOW.md` |
| Receitas de tarefas comuns | `playbooks/<name>.md` |
| Scripts locais (Ollama) | `local-helpers/flow-*.{sh,ps1}` |
| Templates dos 3-arquivos | `prompts/templates/` |
| System prompts e refinement agent | `prompts/` |
| Log de custos manuais | `cost.log` |
| Configs das CLIs | `config/` |
| Trabalho exploratório (não construído) | `docs/architecture/` (ver STATUS.md interno) |
| Docs originais (consolidados aqui) | `docs/legacy/` |

---

## Evolução

Este documento e os playbooks **mudam quando o fluxo real muda**, não antes. Sinais para revisar:

- Estou ignorando uma regra do WORKFLOW na prática → ou a regra está errada, ou eu estou ignorando algo importante. Resolver explicitamente.
- Mesma sequência de prompts copiada 3x → vira playbook.
- Mesma chamada Ollama 3x → vira local helper.
- Categoria de tarefa que não cabe nas 6 acima → adicionar 7ª categoria com regra clara.

Se em algum momento eu sentir que estou construindo uma plataforma em vez de usando uma, paro e leio [`docs/architecture/STATUS.md`](./docs/architecture/STATUS.md) — é o aviso do passado.
