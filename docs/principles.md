# Princípios do AI Dev Flow

Este repo é um **harness de processo** — não apenas uma coleção de configs. Os princípios abaixo descrevem o que este sistema implementa e por quê.

---

## SDD — Spec-Driven Development

**Princípio:** spec antes de código.

Nenhuma implementação começa sem os três artefatos:
- `ARCHITECTURE.md` — o quê e por quê (não como)
- `PROMPT.md` — como executar, fase a fase
- `STATUS.md` — estado atual, ponte entre sessões e ferramentas

Os artefatos são o contrato entre o desenvolvedor e os agentes. Um agente que não leu ARCHITECTURE.md não tem contexto para tomar decisões arquiteturais. Um agente que não leu STATUS.md não sabe onde o projeto está.

**Regra prática:** se a spec não está clara o suficiente para um agente executar sem perguntas, a spec não está pronta.

---

## LLMOps — Operational Practices for LLMs

**Princípio:** tratar agentes de IA como infraestrutura — com gestão de custo, higiene de contexto e observabilidade.

### Gestão de custo
- claude-cli e gemini-cli são assinaturas PRO: sem custo por token
- pi terminal consome créditos OpenRouter: único custo real por token
- Roteamento correto entre ferramentas é a principal alavanca de custo

### Higiene de contexto
- Artefatos (ARCHITECTURE.md, STATUS.md) são a fonte da verdade — não o histórico de chat
- Ao trocar de ferramenta ou abrir nova sessão: leia os artefatos, ignore o chat anterior
- Contexto acumulado em sessão longa = custo crescente; uma fase por sessão é o padrão

### Segmentação de sessão
- Sessão longa (50k+ tokens ou 2h+) = sinal para encerrar
- Fase concluída → commit → STATUS.md atualizado → nova sessão
- Sessões curtas = commits frequentes = rollback fácil

---

## Harness Engineering

**Princípio:** o repositório é o harness que envolve os agentes de IA.

Um harness bem construído faz os agentes operarem de forma consistente independente da ferramenta usada. Este repo é o harness:

- **Scripts** — arranque padronizado para cada ferramenta
- **Agent configs** — definição de papel e modelo por agente
- **Prompts e templates** — contratos de interação com os agentes
- **Routing rules** — quando usar cada ferramenta
- **Artefatos** — ARCHITECTURE.md, PROMPT.md, STATUS.md como interface entre sessões

O desenvolvedor configura o harness uma vez. Os agentes operam dentro dele sem necessidade de re-explicar contexto a cada sessão.

---

## Parallel Workflows

**Princípio:** tarefas independentes podem ser executadas em paralelo em ferramentas diferentes.

Quando duas tarefas não compartilham estado, use ferramentas simultâneas:

| Ferramenta A | Ferramenta B | Condição |
|---|---|---|
| Claude implementa feature | Gemini pesquisa dependências | Sem estado compartilhado |
| Claude escreve arquitetura | Pi explora alternativas | Outputs convergem nos artefatos |
| Claude debugga bug X | Gemini analisa codebase legacy | Contextos isolados |

**Regra de convergência:** o resultado de workflows paralelos sempre converge nos artefatos (ARCHITECTURE.md, STATUS.md) antes do próximo passo sequencial. Nunca merge de outputs direto no chat.
