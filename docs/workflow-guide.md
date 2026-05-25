# Workflow Guide

Como usar o ai-dev-flow no dia a dia de desenvolvimento.

---

## Visão geral do fluxo

```
Demanda
  │
  ▼
[Refinement Agent] ──── Claude Sonnet ou Gemini 2.5 Pro
  │
  ├── ARCHITECTURE.md
  ├── PROMPT.md
  └── STATUS.md
       │
       ▼
[Implementation] ──── Claude Sonnet (main agent)
       │              Claude Haiku (validator/reviewer/documenter)
       │              Gemini Pro (análise de contexto longo)
       │
       ▼
[Fase completa] ──── commit → STATUS.md → nova sessão
```

---

## Ferramentas e custo real

| Ferramenta | Modelo | Tipo de custo | Quando usar |
|---|---|---|---|
| claude-cli | claude-sonnet-4-6 | Assinatura PRO | Default — implementação, arquitetura, debugging |
| gemini-cli | Gemini 2.5 Pro/Flash | Assinatura PRO | Contexto longo, pesquisa web, multimodal |
| pi terminal | Kimi-2.6 (OpenRouter) | **Créditos** (custo real) | Fallback quando quota L1 esgotada |

> Pi é o único ponto de custo real por token no fluxo. Use-o quando claude-cli ou gemini não estiverem disponíveis, não como primeira opção.

---

## Fluxo diário recomendado

### 1. Planejamento (5-10 min)

Antes de codificar, verifique o estado atual:

```bash
# Leia STATUS.md para entender onde parou
cat STATUS.md

# Se tiver Gemini configurado, peça uma análise rápida
./scripts/gemini-start.sh research
# "Qual é o estado atual do projeto em STATUS.md? Próxima fase?"
```

### 2. Implementação (sessão principal)

Use Claude para implementação. Uma sessão = uma fase.

```bash
# Iniciar sessão de implementação
./scripts/claude-start.sh

# Dentro do Claude:
# "Inicie conforme §9 do PROMPT.md"
```

**Ciclo dentro da sessão:**
1. Claude lê ARCHITECTURE.md + STATUS.md + PROMPT.md
2. Lista ambiguidades → você confirma "OK"
3. Descreve plano da fase → você confirma "go"
4. Implementa + testa
5. Atualiza STATUS.md
6. Commit: `Phase N: resumo`
7. Sessão encerra → próxima sessão para próxima fase

### 3. Análise de codebase (quando necessário)

Quando precisar entender um codebase grande ou externo:

```bash
# Análise completa do repo (Gemini carrega tudo de uma vez)
./scripts/gemini-start.sh analyze
# "Analise todo o repositório e mapeie: componentes, dependências, padrões"
```

### 4. Pesquisa (quando necessário)

Para dados atualizados (versões, APIs, best practices):

```bash
# Pesquisa com search grounding
./scripts/gemini-start.sh research
# "Qual é a versão mais recente do FastAPI? Principais breaking changes?"
```

### 5. Fim do dia

Antes de parar:
- STATUS.md atualizado com fase atual
- Commit com descrição clara
- Blocker documentado se houver
- Próxima fase anotada em STATUS.md

---

## Fluxo de novo projeto

### Passo 1: Clone o template

```bash
git clone https://github.com/seu-usuario/ai-dev-flow.git meu-projeto
cd meu-projeto

# Setup (instala CLIs, configura paths)
./scripts/setup.sh        # Mac/Linux
.\scripts\setup.ps1       # Windows
```

### Passo 2: Configure suas API keys

```bash
# Edite .env com suas keys
cp config/.env.example .env
# Preencha ANTHROPIC_API_KEY e GEMINI_API_KEY
```

### Passo 3: Refine a demanda

```bash
./scripts/claude-start.sh refinement
```

O Refinement Agent vai perguntar sobre escopo, stack, usuários, etc. e gerar:
- `ARCHITECTURE.md` — design e decisões
- `PROMPT.md` — roadmap de implementação
- `STATUS.md` — template de tracking

### Passo 4: Inicie a implementação

```bash
# Inicializar git
git init
git add ARCHITECTURE.md PROMPT.md STATUS.md
git commit -m "Initial: architecture and implementation plan"

# Iniciar implementação
./scripts/claude-start.sh
```

---

## Quando trocar de ferramenta mid-session

Troque de ferramenta quando:
- Mensagem de quota esgotada no claude-cli → mude para gemini-cli
- Quota gemini também esgotada → mude para pi (consome créditos)
- Contexto > 100k tokens → mude para gemini independente de quota
- Sessão travada por limite → encerre, atualize STATUS.md, abra na próxima ferramenta

**Nunca carregue contexto do chat ao trocar.** Escreva o estado nos artefatos primeiro.

### Prompt de abertura ao trocar de ferramenta

Use este prompt ao abrir qualquer ferramenta após uma troca:

```
Leia ARCHITECTURE.md, STATUS.md e PROMPT.md.
Fase atual: [X] — [nome da fase].
Retomando de: [ferramenta anterior].
Próximo passo: [tarefa específica].
Liste ambiguidades antes de implementar.
```

---

## Segmentação de sessão

**Regra principal:** uma fase por sessão. Não tente fazer tudo em uma sessão longa.

**Por quê:**
- Contexto acumulado = custo crescente (cada token de histórico é cobrado)
- STATUS.md como ponte elimina a necessidade de re-explicar contexto
- Sessões curtas = commits frequentes = rollback fácil

**Sinais de que está na hora de encerrar:**
- 50k+ tokens de contexto na sessão
- Sessão com 2+ horas
- Fase concluída (commit feito, STATUS.md atualizado)

**Como encerrar bem:**

Na sessão Claude:
```
"Fase X concluída. Atualize STATUS.md e sugira commit message."
```

Depois:
```bash
git add .
git commit -m "Phase X: descrição"
# Nova sessão para próxima fase
```

---

## Quando usar qual modelo

| Situação | Comando | Modelo |
|---|---|---|
| Implementação | `./scripts/claude-start.sh` | Claude Sonnet |
| Review de código | `./scripts/claude-start.sh review` | Claude Haiku |
| Debug complexo | `./scripts/claude-start.sh debug` | Claude Sonnet |
| Análise de repo grande | `./scripts/gemini-start.sh analyze` | Gemini 2.5 Pro |
| Pesquisa de API/lib | `./scripts/gemini-start.sh research` | Gemini 2.5 Flash |
| Analisar screenshot | `./scripts/gemini-start.sh visual` | Gemini 2.5 Pro |
| Refinamento | `./scripts/claude-start.sh refinement` | Claude Sonnet |
| Tarefa simples/budget | `./scripts/gemini-start.sh budget` | Gemini 2.0 Flash |
| Fallback de quota | pi | Kimi-2.6 (OpenRouter) |

Ver [model-routing.md](model-routing.md) para guia detalhado.

---

## Estrutura dos três documentos

### ARCHITECTURE.md
- **O quê** e **por quê** — não implementação
- Componentes, ADRs, stack, fases, riscos
- Referência permanente — edite apenas com aprovação
- Lido pelo modelo no início de cada sessão

### PROMPT.md
- **Como** executar — receita step-by-step
- Fases sequenciais com DoD
- Princípios de execução (branches, commits, testes)
- Kick-off prompt para a sessão de implementação

### STATUS.md
- Estado atual do projeto
- Runtime info (versões, comandos, .env vars)
- Progresso por fase (completo / em progresso / bloqueado)
- Decisões não planejadas + blockers
- **Ponte entre sessões** — atualizado ao fim de cada fase

---

## Checklist de qualidade por fase

Antes de encerrar qualquer fase:

- [ ] Todos os arquivos esperados criados
- [ ] Testes passando (mínimo: happy path + erro + edge case)
- [ ] STATUS.md atualizado (fase, arquivos, testes, blockers)
- [ ] Commit feito: `Phase N: descrição`
- [ ] Nenhuma decisão arquitetural silenciosa (documentar em STATUS.md)
- [ ] Próxima fase planejada em STATUS.md

---

## Troubleshooting

**"O modelo está repetindo contexto já documentado"**
→ Lembre-o: "Não repita conteúdo de ARCHITECTURE.md. Referencie por seção."

**"A sessão está ficando muito longa"**
→ Encerre, atualize STATUS.md, faça commit, abra nova sessão.

**"Preciso de dados de uma API que mudou recentemente"**
→ Use Gemini search: `./scripts/gemini-start.sh research`

**"O codebase é muito grande para Claude ler inteiro"**
→ Use Gemini analyze: `./scripts/gemini-start.sh analyze` (2M token context)

**"Claude não está seguindo PROMPT.md"**
→ Comece a sessão com: "Leia ARCHITECTURE.md, STATUS.md e PROMPT.md. Liste ambiguidades. Aguarde OK."
