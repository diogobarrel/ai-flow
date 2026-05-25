# Forge — Referência Futura

**Status:** em desenvolvimento — não integrado ao fluxo atual.

Este documento descreve a arquitetura planejada para o Forge (Camada 3 do fluxo de desenvolvimento). Serve como referência para quando o Forge estiver estável e pronto para integração.

---

## O que é o Forge

Daemon de execução local que processa tasks de desenvolvimento em background, sem intervenção manual. Usa Ollama + qwen2.5-coder para execução com custo zero.

```
Você (via Claw ou Postgres direto)
  → INSERT dev_tasks com request_text (spec clara)
  → forge daemon LISTEN → pega a task
  → aider + qwen2.5-coder executa
  → aplica mudanças no repo alvo
  → você revisa via git diff
```

---

## Arquitetura planejada

| Componente | Papel |
|---|---|
| Forge daemon | Listener de tasks, orquestrador |
| Ollama + qwen2.5-coder:7b | Execução — tasks mecânicas, rápido (~5GB VRAM) |
| Ollama + qwen2.5-coder:14b | Execução — tasks com mais contexto (~9GB VRAM) |
| Claw / Postgres | Interface de submissão de tasks (mecanismo a definir) |
| git diff | Mecanismo de revisão do output |

---

## Quando o Forge entra no fluxo

O Forge é adequado para tasks que atendem **todos** estes critérios:

- [ ] A spec está clara o suficiente para não gerar perguntas?
- [ ] O escopo é um arquivo ou uma funcionalidade isolada?
- [ ] Um erro de implementação seria visível num git diff?

Se qualquer resposta for "não" → use claude-cli ou pi.

---

## Pré-requisitos para integração

Antes de adicionar o Forge ao fluxo ativo, validar:

1. Forge daemon estável e testado (Fase 1 do ROADMAP do forge concluída)
2. Mecanismo de submissão de tasks definido e funcional (Claw ou Postgres direto)
3. Pelo menos 5 tasks executadas com sucesso e revisadas via git diff
4. Critérios de task adequada validados empiricamente

---

## Evolução planejada

| Fase | Capacidade |
|---|---|
| Fase 1 (atual) | Tasks mecânicas, escopo pequeno, spec explícita |
| Fase 2 | Múltiplos arquivos, contexto do repo alvo |
| Fase 3 | Spec menos rígida, modelo 14b ou cloud (OpenRouter) |
| Fase 4 | Architect + Reviewer separados (LangGraph) |

---

## O que NÃO fazer antes do Forge estar pronto

- Não rotear tasks para o Forge antes da Fase 1 estar fechada
- Não adicionar novos model providers ao Forge antes de validar os locais
- Não migrar para LangGraph antes da Fase 2 estar estável
