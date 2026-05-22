# Architecture — [Nome do Sistema]

**Versão:** 1.0
**Data:** YYYY-MM-DD
**Owner:** [quem]
**Status:** Planejamento / Em progresso / Estável

---

## 1. Overview

[Descrição em 3-5 linhas do que o sistema faz, para quem e por quê.]

---

## 2. Requisitos Funcionais

- RF-1: [requisito com critério de aceitação]
- RF-2: [...]

---

## 3. Requisitos Não-Funcionais

- RNF-1: Performance (ex: <500ms p99)
- RNF-2: Escalabilidade (ex: 10k usuários/dia)
- RNF-3: Segurança (ex: HTTPS, autenticação)
- RNF-4: Observabilidade (logs, métricas, alertas)
- RNF-5: Resiliência (falhas esperadas, retry, fallback)

---

## 4. Componentes Principais

### 4.1 [Nome do Componente]

- **Responsabilidade:** [o que faz]
- **Interface:** [input/output, APIs, eventos]
- **Dependências:** [do que depende]
- **Tecnologia:** [linguagem, framework, lib]

### 4.2 [Próximo Componente]

[mesmo padrão]

---

## 5. Fluxos Críticos

### Fluxo A: [Nome]

```
1. Usuário faz X
2. Sistema valida Y
3. Sistema processa Z
4. Retorna W
```

---

## 6. Architecture Decision Records (ADRs)

### ADR-1: [Tópico]

- **Contexto:** [por que essa decisão precisa ser tomada?]
- **Opções consideradas:** [A], [B], [C]
- **Decisão:** Usar [A]
- **Justificativa:** [trade-offs, benefícios]
- **Consequências:** [impactos futuros]

### ADR-2: [...]

---

## 7. Estrutura de Diretórios

```
projeto/
├── src/
│   ├── core/          # lógica principal
│   ├── api/           # endpoints HTTP
│   ├── db/            # models, migrations
│   ├── tools/         # utilitários
│   └── config/        # configurações
├── tests/
├── infra/             # scripts, docker, deploy
├── docs/
├── ARCHITECTURE.md
├── PROMPT.md
├── STATUS.md
└── requirements.txt   # ou package.json, pyproject.toml
```

---

## 8. Tech Stack

| Aspecto | Escolha | Versão mínima | Justificativa |
|---|---|---|---|
| Linguagem | [ex: Python] | [ex: 3.11+] | [por quê] |
| Framework | [ex: FastAPI] | [ex: 0.115+] | [por quê] |
| Banco de dados | [ex: PostgreSQL] | [ex: 15+] | [por quê] |
| ORM | [ex: SQLAlchemy] | [ex: 2.0+] | [por quê] |
| Testes | [ex: pytest] | [ex: 8.0+] | [por quê] |
| CI/CD | [ex: GitHub Actions] | — | [por quê] |
| Deploy | [ex: Docker] | — | [por quê] |

---

## 9. Fases de Implementação

### Fase 0: Scaffolding & Infraestrutura

- Criar estrutura de diretórios
- Setup banco de dados (local + Docker)
- Setup framework de testes
- Pipeline CI/CD inicial
- **DoD:** ambiente rodando localmente, testes passando

### Fase 1: [Nome]

[mesmo padrão]

### Fase N: [...]

---

## 10. Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| [Risco A] | Alta | Alta | [ação preventiva] |
| [Risco B] | Média | Média | [ação preventiva] |

---

## 11. Dependências Externas

- API X (autenticação: API key, rate limit: 100/min)
- Serviço Y (SLA de uptime: 99.9%, custo: $X/mês)
- Biblioteca Z (licença: MIT, manutenção: ativa)

---

## 12. Notas e Trabalho Futuro

- [item para depois]
- [item para depois]

---

## Changelog de Decisões

| Data | Decisão | Impacto | Aprovado por |
|---|---|---|---|
| YYYY-MM-DD | [descrição] | [fase afetada] | [quem] |
