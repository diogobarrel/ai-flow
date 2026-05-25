# Routing Rules — Qual ferramenta usar

Guia de decisão para selecionar a ferramenta correta por tipo de tarefa e disponibilidade de quota.

---

## Ferramentas disponíveis

| Ferramenta | Modelo | Tipo de custo |
|---|---|---|
| claude-cli | claude-sonnet-4-6 / haiku | Assinatura PRO |
| gemini-cli | Gemini 2.5 Pro / Flash | Assinatura PRO |
| pi terminal | Kimi-2.6 (OpenRouter) | Créditos OpenRouter |

---

## Tabela de roteamento

| Situação | Ferramenta | Justificativa |
|---|---|---|
| Default — arquitetura, implementação, debugging | claude-cli | Melhor raciocínio de código; assinatura sem custo adicional |
| Contexto > 100k tokens (codebase grande) | gemini | Context window 2M vs 200k |
| Pesquisa web / dados recentes | gemini | Search grounding nativo |
| Análise de imagens, screenshots, PDFs | gemini | Multimodal superior |
| Quota Claude esgotada | pi | Fallback cloud; consome créditos |
| Quota Claude E Gemini esgotadas | pi | Único path disponível |
| Sessão conversacional longa com quota baixa | pi | Mid-complexity iterativa |
| Rotinas (lint, docs, review) | claude-cli / haiku | Haiku é mais barato dentro da assinatura |

---

## Árvore de decisão

```
Tarefa recebida
│
├── Claude quota disponível?
│   └── SIM → claude-cli
│
├── Contexto > 100k tokens ou precisa de search?
│   └── SIM → gemini-cli
│
├── Gemini disponível?
│   └── SIM → gemini-cli
│
└── Fallback → pi (consome créditos OpenRouter)
```

---

## Regras de ouro

1. **claude-cli é o default** — assinatura PRO, sem custo por sessão.
2. **gemini para volume e pesquisa** — contexto 2M e search grounding são diferenciais únicos.
3. **pi é fallback de quota, não de qualidade** — consome créditos reais; reserve para quando L1 estiver indisponível.
4. **Modelos locais não funcionam no Pi** — não tente usar Ollama via Pi terminal.
5. **O bridge entre ferramentas é sempre ARCHITECTURE.md + PROMPT.md + STATUS.md** — nunca carregue contexto do chat ao trocar de ferramenta.

---

## Handoff entre ferramentas

Ao trocar de ferramenta mid-session, preserve o contexto nos artefatos — não no histórico de chat.

**Prompt de abertura padrão (qualquer ferramenta):**
```
Leia ARCHITECTURE.md, STATUS.md e PROMPT.md.
Fase atual: [X]. Tarefa específica: [descrição].
Liste ambiguidades antes de implementar.
```

**Sinais de que é hora de trocar de ferramenta:**
- Mensagem de quota esgotada → troque para próxima ferramenta disponível
- Contexto > 100k tokens → mude para gemini independente de quota
- Sessão travada por limite de contexto → encerre, atualize STATUS.md, abra nova sessão na próxima ferramenta
