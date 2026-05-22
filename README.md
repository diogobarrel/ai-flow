# ai-dev-flow

> Template de workflow de desenvolvimento com IA — Claude + Gemini CLI

Um repositório base para formalizar e padronizar o uso de modelos de IA (Claude e Gemini) em projetos de desenvolvimento de software. Inclui agentes especializados, system prompts otimizados, scripts de setup e guias de quando usar cada modelo.

---

## O que é isso?

Este repo é um **template de workflow** — não um projeto de software, mas a infraestrutura de processo que você clona, adapta ao seu projeto e usa como base para todos os seus projetos de desenvolvimento com IA.

A ideia central: antes de escrever uma linha de código, você define arquitetura, fases e regras de interação com o modelo. Isso reduz custo, aumenta consistência e mantém o contexto organizado entre sessões.

---

## Estrutura do repositório

```
ai-dev-flow/
├── README.md                        # Este arquivo
│
├── agents/
│   ├── claude-agents.json           # Agentes Claude (Sonnet/Haiku)
│   ├── gemini-agents.json           # Agentes Gemini (Pro/Flash)
│   └── routing-rules.md             # Quando usar Claude vs Gemini
│
├── prompts/
│   ├── system-prompt-claude.md      # System prompt para Claude Code CLI
│   ├── system-prompt-gemini.md      # System prompt para Gemini CLI
│   ├── refinement-agent.md          # Agente de refinamento de demandas
│   └── templates/
│       ├── ARCHITECTURE.md          # Template de arquitetura do projeto
│       ├── PROMPT.md                # Template de instrução de implementação
│       └── STATUS.md                # Template de tracking de progresso
│
├── scripts/
│   ├── setup.sh                     # Setup inicial (Unix/Mac)
│   ├── setup.ps1                    # Setup inicial (Windows)
│   ├── claude-start.sh              # Wrapper para sessão Claude (Unix)
│   ├── claude-start.ps1             # Wrapper para sessão Claude (Windows)
│   ├── gemini-start.sh              # Wrapper para sessão Gemini (Unix)
│   └── gemini-start.ps1             # Wrapper para sessão Gemini (Windows)
│
├── config/
│   ├── claude-settings.json         # Configurações Claude CLI
│   ├── gemini-settings.json         # Configurações Gemini CLI
│   └── .env.example                 # Variáveis de ambiente necessárias
│
└── docs/
    ├── workflow-guide.md            # Como usar este workflow
    └── model-routing.md             # Guia detalhado de roteamento de modelos
```

---

## Quickstart

### 1. Clone e configure

```bash
# Clone o template
git clone https://github.com/seu-usuario/ai-dev-flow.git meu-projeto
cd meu-projeto

# Execute o setup (instala CLIs, configura paths)
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 2. Refine sua demanda

Use o agente de refinamento para transformar sua demanda em 3 arquivos estruturados:

**Com Claude:**
```bash
claude --system-prompt-file prompts/refinement-agent.md --model sonnet
```

**Com Gemini:**
```bash
gemini --system-prompt-file prompts/refinement-agent.md --model gemini-2.5-pro
```

O agente vai gerar para o seu projeto:
- `ARCHITECTURE.md` — design, decisões, ADRs
- `PROMPT.md` — roadmap de implementação em fases
- `STATUS.md` — tracking de progresso

### 3. Inicie a implementação

```bash
# Usando Claude Code (recomendado para implementação)
./scripts/claude-start.sh

# Usando Gemini CLI (recomendado para análise de codebase grande)
./scripts/gemini-start.sh
```

---

## Quando usar cada modelo

| Tarefa | Modelo recomendado | Por quê |
|---|---|---|
| Implementação de código | Claude Sonnet | Melhor qualidade de código, instruction-following |
| Validação / linting | Claude Haiku | Rápido e barato para tarefas rotineiras |
| Análise de codebase grande (>100k tokens) | Gemini 2.5 Pro | Context window de 2M tokens |
| Pesquisa com dados recentes | Gemini 2.5 Flash | Search grounding nativo |
| Análise de imagens/screenshots | Gemini 2.5 Pro | Multimodal superior |
| Documentação técnica | Claude Haiku ou Gemini Flash | Custo-eficiente |
| Decisões de arquitetura | Claude Sonnet | Raciocínio consistente |
| Refatoração de arquivo único | Claude Sonnet | Edição precisa |

Ver [`agents/routing-rules.md`](agents/routing-rules.md) para regras detalhadas.

---

## Modelos disponíveis

### Claude (Anthropic)
| Modelo | String | Uso |
|---|---|---|
| Claude Sonnet 4.5 | `claude-sonnet-4-5` | Implementação, arquitetura |
| Claude Haiku 4.5 | `claude-haiku-4-5-20251001` | Validação, docs, review |

### Gemini (Google)
| Modelo | String | Uso |
|---|---|---|
| Gemini 2.5 Pro | `gemini-2.5-pro` | Análise de codebase, multimodal |
| Gemini 2.5 Flash | `gemini-2.5-flash` | Pesquisa, tarefas rápidas |
| Gemini 2.0 Flash | `gemini-2.0-flash` | Budget, automações simples |

---

## Princípios do workflow

1. **Contexto por referência** — nunca cole arquivos inteiros; referencie por path e linha
2. **Uma fase por sessão** — segmente o trabalho; cada sessão = uma fase = um commit
3. **Roteamento por complexidade** — use o modelo mais barato que resolve a tarefa
4. **STATUS.md como ponte** — é o único arquivo que conecta sessões; mantenha atualizado
5. **ADRs explícitos** — toda decisão arquitetural vai documentada no ARCHITECTURE.md

---

## Dependências

- [Claude Code CLI](https://docs.claude.ai/cli) — `npm install -g @anthropic-ai/claude-code`
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) — `npm install -g @google/gemini-cli`
- Node.js 18+
- Git

> **Sem API keys necessárias.** Ambas as CLIs autenticam via conta — Claude Code usa sua conta Claude.ai, Gemini CLI usa sua conta Google (`gemini auth login`). API keys só são necessárias se você for chamar as APIs diretamente via SDK.

---

## Docs

- [Workflow Guide](docs/workflow-guide.md) — como usar este workflow dia a dia
- [Model Routing](docs/model-routing.md) — guia detalhado de seleção de modelos
- [Refinement Agent](prompts/refinement-agent.md) — como transformar demandas em planos executáveis

---

## Licença

MIT
