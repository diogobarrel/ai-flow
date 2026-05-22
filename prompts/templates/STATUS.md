# Project Status — [Nome do Sistema]

Tracking central de progresso, runtime info, decisões e blockers.

---

## Metadados do Projeto

| Campo | Valor |
|---|---|
| **Projeto** | [Nome] |
| **Descrição** | [1-2 linhas] |
| **Owner** | [quem] |
| **Data de início** | YYYY-MM-DD |
| **Data alvo de corte** | YYYY-MM-DD |
| **Versão alvo** | v1.0.0 |
| **Branch de implementação** | `v1-implementation` |
| **Status geral** | Em progresso / Bloqueado / Pronto para corte |
| **Modelos em uso** | Claude Sonnet (main), Claude Haiku (rotinas), [Gemini se aplicável] |

---

## Runtime Info

Informações de ambiente, versões e comandos comuns.

### Versões Necessárias

```
[Linguagem]: [versão]+
Docker: [versão]+
Docker Compose: [versão]+
[Banco de dados]: [versão]+ (via Docker)
[Outra ferramenta]: [versão]
```

### Variáveis de Ambiente

`.env` esperado com:
```
DATABASE_URL=[string de conexão]
API_PORT=8000
LOG_LEVEL=info
[OUTRA_VAR]=valor
```

### Comandos Comuns

```bash
# Setup inicial
[comando de instalação de dependências]
[comando de ativação de venv se aplicável]

# Rodar testes
[comando de teste]

# Rodar servidor de dev
[comando de dev server]

# Banco de dados
docker compose up -d [serviço]

# Migrations (se aplicável)
[comando de migration]

# Commits
git checkout -b v1-implementation
git add .
git commit -m "Phase N: descrição"
```

### Estrutura de Diretórios (Confirmada)

```
[copie de ARCHITECTURE.md §7 após confirmação]
```

---

## Fases de Implementação

### Fase 0 (YYYY-MM-DD) — Scaffolding & Infraestrutura

**Status:** ⏳ Em progresso / ✅ Completo / ❌ Bloqueado

**Implementado:**
- [ ] Estrutura de diretórios
- [ ] Docker Compose
- [ ] Dependências
- [ ] Framework de testes
- [ ] CI/CD inicial

**Testes:**
- ✅ X passando / Y total

**Arquivos Criados:**
- `docker-compose.yml`
- `[arquivo de dependências]`
- `tests/test_health.py`
- [...]

**Blockers:** Nenhum

**Próxima fase:** Fase 1

---

### Fase 1 — [Nome]

[mesmo padrão]

---

## Decisões Não Planejadas

Decisões tomadas durante a implementação **que não estavam previstas em ARCHITECTURE.md**.

### Decisão 1: [Tópico]

- **Data:** YYYY-MM-DD
- **Contexto:** [por que essa decisão precisou ser tomada?]
- **Decisão:** [o que foi decidido]
- **Justificativa:** [trade-offs, impacto]
- **Fase afetada:** Fase X
- **Impacto em ARCHITECTURE.md?** Sim / Não → [se sim, nota datada foi adicionada]

### Decisão 2: [...]

---

## Blockers e Impedimentos

Problemas que impedem o progresso.

### Blocker A

- **Data descoberta:** YYYY-MM-DD
- **Descrição:** [o que concretamente]
- **Impacto:** [qual fase é afetada]
- **Status de resolução:** Aberto / Em progresso / Resolvido
- **Tentativas:**
  1. [tentativa 1]
  2. [tentativa 2]
- **Próxima ação:** [o que tentar]

---

## Histórico de Commits

```
Phase 0: scaffolding + infra
Phase 1: [nome]
[...]
```

(Manter sincronizado com `git log --oneline`)

---

## Notas e Observações

- [nota relevante]
- [decisão de produto]
- [aprendizado importante]

---

## Links Úteis

- ARCHITECTURE.md → design e decisões
- PROMPT.md → instruções de execução
- Repo: [URL GitHub/GitLab]
- Projeto: [URL Jira/Linear/etc se existir]

---
