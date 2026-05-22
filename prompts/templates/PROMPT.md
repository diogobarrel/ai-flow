# Implementation Prompt — v1 [Nome do Sistema]

Este arquivo é o **kick-off prompt** para iniciar a implementação via Claude Code CLI ou Gemini CLI. Toda a arquitetura está finalizada em `ARCHITECTURE.md`.

---

## 1. Seu papel

Você é o engenheiro responsável pela implementação end-to-end conforme descrito em `ARCHITECTURE.md`.

O usuário (owner) é experiente em engenharia. Quando houver decisão técnica não documentada, **pergunte antes de implementar**. Não improvise arquitetura.

---

## 2. Leitura obrigatória ANTES de qualquer código

**Na primeira ação**, leia **nesta ordem**:

1. `ARCHITECTURE.md` — fonte de verdade (design, decisões, stack)
2. `STATUS.md` — estado atual do projeto
3. Este arquivo (`PROMPT.md`)

Após ler, **liste todas as ambiguidades** encontradas em `ARCHITECTURE.md` e aguarde "OK" do usuário.

---

## 3. Princípios de execução

### 3.1 Trabalhe em Fases — Uma por vez

- Implementação dividida em N fases (§8)
- NÃO pule fases
- NÃO inicie próxima fase sem a anterior estar **100% pronta**

Requisitos para "pronta":
- Todos os arquivos esperados criados
- Definition of Done alcançado
- Testes passando
- `STATUS.md` atualizado
- Commit dedicado

### 3.2 Branch e Commits

- Trabalhe em branch dedicada: `v1-implementation` (criada a partir de `main`)
- Um commit por fase: `Phase N: <resumo>`
- Nunca faça push para `origin/main` até o corte final
- Tags `vX.Y.Z` apenas após fases estáveis

### 3.3 Validação de Ambiente

Antes da Fase 0, valide:
- [Linguagem/runtime] versão mínima ativa (ex: `python --version`)
- Docker disponível (`docker --version`)
- [Ferramentas específicas do projeto]
- Se algo faltar, **pare e reporte**. Não tente "contornar".

### 3.4 Atualize `STATUS.md` ao final de cada fase

Após cada fase, adicione bloco:

```markdown
## Fase N (YYYY-MM-DD) — [Nome]
- Implementado: [lista curta]
- Testes: X passando / Y total
- Arquivos novos: [count ou paths chave]
- Blockers: [se houver]
- Próxima fase: N+1
```

### 3.5 Testes acompanham o código

- Nenhuma fase entrega sem testes
- Mínimo: happy path + 1 caso de erro + 1 edge case
- Suite roda com `pytest` (ou framework apropriado)
- Sem dependências de rede em testes unitários (mock tudo)

### 3.6 Confirmação antes de operações destrutivas

NUNCA execute sem confirmação explícita:
- `DROP TABLE` / `DROP DATABASE`
- `rm -rf` em qualquer diretório do projeto
- `git push --force` ou qualquer push para `origin/main`
- Deploys reais (staging/prod)

### 3.7 Zonas protegidas

Não modifique sem permissão:
- `ARCHITECTURE.md` — edite apenas se desvio aprovado (nota datada)
- `.git/`, `.venv/`, `__pycache__/`, `node_modules/`
- [Outras pastas sensíveis do projeto]

### 3.8 Desvio arquitetural

Se encontrar que `ARCHITECTURE.md` está incompleto/errado/impraticável:

1. **Pare**
2. Descreva o problema concretamente
3. Proponha 2-3 alternativas com trade-offs
4. Aguarde decisão do usuário
5. Após decisão, atualize `ARCHITECTURE.md` (nota datada)

Nunca improvise arquitetura silenciosamente.

---

## 4. Stack de Dependências Final

[Gere conforme ARCHITECTURE.md §8, em formato requirements.txt / pyproject.toml / package.json]

---

## 5. Estrutura de Diretórios Alvo

[Copie de ARCHITECTURE.md §7]

---

## 6. Princípios Técnicos

| Aspecto | Padrão |
|---|---|
| Linguagem | [conforme ARCHITECTURE.md] |
| Type hints | Obrigatório em todos os públicos |
| Imports | Absolutos (ex: `from core.auth import ...`) |
| Secrets | SEMPRE via `.env`, NUNCA hardcoded |
| Formatação | [ferramenta configurada no projeto] |
| Logging | [framework configurado] |
| Error handling | Estruturado, mensagens claras |
| Async | [sync ou async, conforme stack] |

---

## 7. Como interagir comigo

- **Ao iniciar cada fase:** descreva em 3-5 linhas o que fará; aguarde "go"
- **Ao terminar cada fase:** mostre STATUS.md atualizado, lista de arquivos, resultados de testes
- **Ambiguidade em ARCHITECTURE.md:** pergunte; não improvise
- **Desvio arquitetural necessário:** pare, proponha alternativas, aguarde decisão
- **Erro/blocker:** descreva concretamente, mostre logs, proponha hipótese
- **NÃO entregue múltiplas fases juntas** — quero validar uma por vez

---

## 8. Fases de Implementação

[Gere com base em ARCHITECTURE.md §9]

### Fase 0 — Scaffolding & Infraestrutura

**Escopo:**
- Estrutura de diretórios
- Setup banco de dados (Docker)
- requirements/dependências
- Framework de testes
- CI/CD inicial

**DoD:**
- `pytest` roda sem erros
- Docker compose sobe serviços
- Pelo menos 1 teste de health passando

**Commit:** `Phase 0: scaffolding + infra`

---

### Fase 1 — [Nome]

[mesmo padrão]

---

## 9. Primeira ação desta sessão

Faça **exatamente** isso, em ordem:

1. Crie a branch `v1-implementation` a partir da branch atual
2. Leia os 3 arquivos: ARCHITECTURE.md, STATUS.md, este PROMPT.md
3. Valide o ambiente conforme §3.3
4. **Liste todas as ambiguidades** encontradas em ARCHITECTURE.md
5. Aguarde "OK" do usuário
6. Com OK, descreva plano detalhado da Fase 0
7. Aguarde "go"
8. Execute a Fase 0

**Não pule etapas.** Cada fase sólida é a base da próxima.

Vamos lá.

---
