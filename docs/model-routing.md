# Model Routing Guide

Guia detalhado para selecionar o modelo certo por tipo de tarefa, com justificativas e exemplos práticos.

---

## Por que routing importa

| Cenário | Sem routing | Com routing | Economia |
|---|---|---|---|
| Projeto 8 fases | Claude Sonnet 100% | Sonnet 40% + Haiku 50% + Gemini 10% | ~50% |
| Code review | Sonnet ($0.015/1k) | Haiku ($0.0025/1k) | ~83% |
| Pesquisa de API | Sonnet | Gemini Flash ($0.000075/1k) | ~99% |
| Codebase 500k tokens | Falha (limite 200k) | Gemini 2.5 Pro (2M limit) | Funciona |

---

## Claude: quando usar

### Claude Sonnet 4.5 — Implementação e Arquitetura

**Use para:**
- Implementar features com lógica complexa
- Decisões de arquitetura (nunca delegue para Haiku)
- Refatoração com constraints múltiplos
- Debugging quando o erro não é óbvio
- Qualquer tarefa que exija raciocínio multi-step

**Não use para:**
- Tarefas determinísticas (linting, formatting)
- Validação de sintaxe
- Geração de boilerplate previsível
- Pesquisa de dados recentes
- Análise de imagens

**Exemplo de uso:**
```bash
./scripts/claude-start.sh
# Tarefa: "Implemente autenticação JWT com refresh tokens conforme ARCHITECTURE.md §4.2"
```

---

### Claude Haiku 4.5 — Rotinas e Validação

**Use para:**
- Executar e reportar resultados de testes
- Linting e checagem de estilo
- Escrever docstrings e comentários inline
- Code review de qualidade/padrões
- Gerar changelog entries
- Atualizar README sections

**Não use para:**
- Decisões de design
- Debugging complexo
- Qualquer coisa que exija julgamento arquitetural

**Como ativar:**
```bash
# No Claude Code CLI, dentro de uma sessão:
/use validator
/use reviewer
/use documenter
```

---

## Gemini: quando usar

### Gemini 2.5 Pro — Contexto Longo e Multimodal

**Use para:**
- Analisar codebases > 100k tokens (context 2M)
- Análise de screenshots, mockups, diagramas
- Leitura de PDFs técnicos extensos
- Refinamento de demandas complexas
- Entender arquitetura de projetos legados grandes

**Diferencial chave:** context window de 2M tokens — pode carregar um repo inteiro e fazer perguntas sobre ele.

**Exemplo:**
```bash
./scripts/gemini-start.sh analyze
# "Analise todo o src/ e liste: componentes, suas responsabilidades e dependências entre eles"
```

---

### Gemini 2.5 Flash — Pesquisa e Velocidade

**Use para:**
- Verificar versões mais recentes de bibliotecas
- Pesquisar best practices atualizadas
- Consultar documentação de APIs externas
- Verificar breaking changes antes de atualizar dependências
- Qualquer pergunta que precise de dados de 2024-2025

**Diferencial chave:** search grounding nativo — acessa internet em tempo real.

**Exemplo:**
```bash
./scripts/gemini-start.sh research
# "Qual versão mais estável do FastAPI? Algum breaking change entre 0.110 e 0.115?"
```

---

### Gemini 2.0 Flash — Budget e Automações

**Use para:**
- Formatar dados (JSON → CSV, etc.)
- Gerar dados de teste (fixtures, mocks)
- Tarefas repetitivas e previsíveis
- Automações simples de texto

**Diferencial chave:** custo mais baixo disponível, adequado para volume.

```bash
./scripts/gemini-start.sh budget
```

---

---

### Pi terminal / Kimi-2.6 — Fallback de quota

**Use para:**
- Implementação iterativa quando quota claude-cli ou gemini esgotada
- Sessões conversacionais mid-complexity
- Qualquer tarefa que precise de um agente cloud disponível agora

**Não use para:**
- Tarefas que podem esperar quota claude-cli ser restaurada (evite custo)
- Análise de contexto muito longo (sem vantagem sobre Claude em contexto curto)

**Limitação importante:** modelos locais Ollama testados e incompatíveis com Pi terminal. Único modelo disponível é Kimi-2.6 via OpenRouter.

**Custo:** créditos OpenRouter — único custo real por token no fluxo atual.

---

## Matriz de capacidades

| Capacidade | Claude Sonnet | Claude Haiku | Gemini 2.5 Pro | Gemini 2.5 Flash | Gemini 2.0 Flash | Pi / Kimi-2.6 |
|---|---|---|---|---|---|---|
| Context window | 200k | 200k | **2M** | 1M | 1M | 128k |
| Qualidade de código | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| Instruction-following | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| Velocidade | Médio | Rápido | Médio | **Muito rápido** | **Mais rápido** | Rápido |
| **Tipo de custo** | **Assinatura** | **Assinatura** | **Assinatura** | **Assinatura** | **Assinatura** | **Créditos** |
| Search grounding | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ |
| Multimodal | Limitado | ❌ | ✅⭐⭐⭐⭐⭐ | ✅⭐⭐⭐ | ✅⭐⭐ | ❌ |
| Raciocínio de código | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| Agente / tool use | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |

---

## Fluxo híbrido recomendado

```
Demanda de engenharia
        │
        ▼
[Gemini 2.5 Pro] ─── Se há muito contexto para ler
[Claude Sonnet]  ─── Se a demanda é mais focada
        │
        ▼ Gera ARCHITECTURE.md + PROMPT.md + STATUS.md
        │
        ▼
[Claude Sonnet] ─── Implementação fase a fase
        │
        ├── [Claude Haiku] ─── Testes + validação + docs
        │
        ├── [Gemini 2.5 Flash] ─── Pesquisa de libs/APIs quando necessário
        │
        └── [Gemini 2.5 Pro] ─── Análise de contexto longo quando necessário
```

---

## Regras de decisão rápida

```
É uma imagem ou PDF?
  → Gemini 2.5 Pro (visual)

O codebase/contexto é > 100k tokens?
  → Gemini 2.5 Pro (analyst)

Precisa de dados de 2024 ou mais recentes?
  → Gemini 2.5 Flash (researcher)

É uma decisão de arquitetura?
  → Claude Sonnet, NUNCA Haiku

É rotina (teste / lint / doc / review)?
  → Claude Haiku

É tarefa trivial (formatar / gerar fixture)?
  → Gemini 2.0 Flash ou Claude Haiku

Quota claude-cli E gemini esgotadas?
  → Pi terminal (Kimi-2.6 via OpenRouter — consome créditos)

Default?
  → Claude Sonnet
```

---

## Custo de referência (aproximado)

| Modelo | Input (por 1M tokens) | Output (por 1M tokens) |
|---|---|---|
| Claude Sonnet 4.5 | ~$3 | ~$15 |
| Claude Haiku 4.5 | ~$0.25 | ~$1.25 |
| Gemini 2.5 Pro | ~$1.25 | ~$10 |
| Gemini 2.5 Flash | ~$0.075 | ~$0.30 |
| Gemini 2.0 Flash | ~$0.01 | ~$0.04 |

*Preços variam — verifique pricing atual antes de projetos grandes.*

---

## Configurando routing automático

No `config/claude-settings.json`:

```json
"modelRouting": {
  "enabled": true,
  "rules": {
    "architecture": "claude-sonnet-4-5",
    "implementation": "claude-sonnet-4-5",
    "testing": "claude-haiku-4-5-20251001",
    "review": "claude-haiku-4-5-20251001",
    "documentation": "claude-haiku-4-5-20251001"
  }
}
```

No `agents/claude-agents.json`:
- `main` → Sonnet para decisões complexas
- `validator`, `reviewer`, `documenter`, `debugger` → Haiku para rotinas

No `agents/gemini-agents.json`:
- `analyst` → 2.5 Pro para contexto longo
- `researcher` → 2.5 Flash para pesquisa
- `visual` → 2.5 Pro para multimodal
- `budget` → 2.0 Flash para tarefas triviais
