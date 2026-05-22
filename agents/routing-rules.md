# Routing Rules — Claude vs Gemini

Guia de decisão para selecionar o modelo correto por tipo de tarefa.

---

## Regra geral

```
Complexidade alta + código = Claude Sonnet
Rotina + validação = Claude Haiku
Contexto grande (>100k tokens) = Gemini 2.5 Pro
Pesquisa / dados recentes = Gemini 2.5 Flash
Imagens / multimodal = Gemini 2.5 Pro
Tarefas simples / budget = Gemini 2.0 Flash ou Claude Haiku
```

---

## Tabela de roteamento

| Tarefa | Modelo | Agente | Justificativa |
|---|---|---|---|
| Implementar feature complexa | Claude Sonnet | `main` | Melhor raciocínio de código, instruction-following |
| Implementar boilerplate/CRUD | Claude Haiku | `main` (downgraded) | Padrão previsível, custo menor |
| Executar testes | Claude Haiku | `validator` | Tarefa determinística |
| Linting e formatação | Claude Haiku | `validator` | Rotina, output estruturado |
| Code review | Claude Haiku | `reviewer` | Padrões são conhecidos |
| Escrever docstrings | Claude Haiku | `documenter` | Templating |
| Atualizar README | Claude Haiku | `documenter` | Escrita simples |
| Debugar erro complexo | Claude Sonnet | `debugger` (upgraded) | Requer raciocínio profundo |
| Debugar erro simples | Claude Haiku | `debugger` | Stack trace óbvio |
| Decisão de arquitetura | Claude Sonnet | `main` | Nunca delegar para Haiku |
| Analisar codebase inteiro | Gemini 2.5 Pro | `analyst` | Context window 2M > 200K |
| Entender dependências | Gemini 2.5 Pro | `analyst` | Visão global do repo |
| Pesquisar biblioteca/API | Gemini 2.5 Flash | `researcher` | Search grounding |
| Verificar versões recentes | Gemini 2.5 Flash | `researcher` | Dados atualizados |
| Analisar screenshot de erro | Gemini 2.5 Pro | `visual` | Multimodal |
| Analisar mockup/wireframe | Gemini 2.5 Pro | `visual` | Multimodal |
| Ler PDF de documentação | Gemini 2.5 Pro | `visual` | Extração de contexto |
| Refinamento de demanda | Gemini 2.5 Pro | `refiner` | Contexto longo, raciocínio |
| Geração de ARCHITECTURE.md | Claude Sonnet ou Gemini 2.5 Pro | — | Ambos adequados |
| Formatar JSON/YAML | Gemini 2.0 Flash | `budget` | Tarefa trivial |
| Gerar dados de teste | Gemini 2.0 Flash | `budget` | Templating simples |
| Converter formato de arquivo | Gemini 2.0 Flash | `budget` | Transformação determinística |

---

## Árvore de decisão

```
Tarefa recebida
│
├── Envolve imagem, PDF ou screenshot?
│   └── SIM → Gemini 2.5 Pro (visual)
│
├── Contexto > 100k tokens (codebase grande, múltiplos arquivos)?
│   └── SIM → Gemini 2.5 Pro (analyst)
│
├── Precisa de dados recentes / pesquisa web?
│   └── SIM → Gemini 2.5 Flash (researcher)
│
├── É decisão de arquitetura ou implementação complexa?
│   └── SIM → Claude Sonnet (main)
│
├── É rotina de validação, teste, lint, docs?
│   └── SIM → Claude Haiku (validator/documenter/reviewer)
│
├── É tarefa trivial/formatação?
│   └── SIM → Gemini 2.0 Flash (budget) ou Claude Haiku
│
└── Default → Claude Sonnet
```

---

## Custo relativo (referência)

| Modelo | Custo relativo | Velocidade |
|---|---|---|
| Claude Sonnet 4.5 | 3x | Médio |
| Claude Haiku 4.5 | 1x | Rápido |
| Gemini 2.5 Pro | 3-4x | Médio |
| Gemini 2.5 Flash | 0.5x | Rápido |
| Gemini 2.0 Flash | 0.1x | Muito rápido |

**Target de eficiência:** 60%+ das requests via modelos baratos (Haiku ou Flash).

---

## Regras de ouro

1. **Nunca use Sonnet/Pro para tarefas determinísticas** — se o output é previsível, Haiku/Flash resolve.
2. **Codebase > 100k tokens → sempre Gemini** — Claude tem limite de 200k, Gemini tem 2M.
3. **Pesquisa web → sempre Gemini Flash** — tem search grounding nativo; Claude não.
4. **Decisões de arquitetura → sempre Claude Sonnet** — melhor raciocínio estruturado para código.
5. **Multimodal → sempre Gemini 2.5 Pro** — análise de imagens/screenshots superiores.
6. **Em dúvida → Claude Sonnet** — mais consistente em instruction-following.

---

## Configuração de agentes por projeto

No seu projeto, copie e adapte os agentes conforme o stack:

```bash
# Para projeto Python/backend (mais Claude)
cp agents/claude-agents.json meu-projeto/agents.json

# Para projeto com codebase grande (mais Gemini)
cp agents/gemini-agents.json meu-projeto/gemini-agents.json

# Workflow híbrido (ambos)
# Use claude-agents.json para implementação
# Use gemini-agents.json para análise e pesquisa
```
