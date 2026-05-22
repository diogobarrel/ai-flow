#!/usr/bin/env bash
# claude-start.sh — Inicia sessão Claude Code otimizada
#
# Uso:
#   ./scripts/claude-start.sh                    # sessão de implementação
#   ./scripts/claude-start.sh refinement         # agente de refinamento
#   ./scripts/claude-start.sh review             # revisão de código
#   ./scripts/claude-start.sh debug              # debugging

set -e

MODE="${1:-impl}"
MODEL="${2:-sonnet}"
EFFORT="${3:-high}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Verificar se claude está instalado e autenticado
if ! command -v claude &> /dev/null; then
    echo "[FAIL] Claude Code CLI não encontrado"
    echo "  Instale com: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

# Selecionar system prompt por modo
case "$MODE" in
    refinement|refine|r)
        SYSTEM_PROMPT_FILE="$PROJECT_DIR/prompts/refinement-agent.md"
        echo "[INFO] Modo: Refinamento de demanda"
        echo "[INFO] Modelo: claude-sonnet (recomendado para refinamento)"
        ;;
    review|rev)
        SYSTEM_PROMPT_FILE="$PROJECT_DIR/prompts/templates/PROMPT.md"
        MODEL="haiku"
        echo "[INFO] Modo: Code review (Haiku — custo otimizado)"
        ;;
    debug|d)
        SYSTEM_PROMPT_FILE="$PROJECT_DIR/prompts/templates/PROMPT.md"
        echo "[INFO] Modo: Debugging"
        ;;
    impl|implementation|*)
        if [ -f "$PROJECT_DIR/PROMPT.md" ]; then
            SYSTEM_PROMPT_FILE="$PROJECT_DIR/PROMPT.md"
            echo "[INFO] Modo: Implementação (usando PROMPT.md do projeto)"
        else
            SYSTEM_PROMPT_FILE="$PROJECT_DIR/prompts/templates/PROMPT.md"
            echo "[WARN] PROMPT.md não encontrado no projeto — usando template"
            echo "[WARN] Execute o refinement agent primeiro para gerar PROMPT.md"
        fi
        ;;
esac

# Verificar se agentes config existe
AGENTS_FLAG=""
if [ -f "$HOME/.claude/agents.json" ]; then
    echo "[INFO] Agentes: carregados de ~/.claude/agents.json"
elif [ -f "$PROJECT_DIR/agents/claude-agents.json" ]; then
    AGENTS_FLAG="--agents $PROJECT_DIR/agents/claude-agents.json"
    echo "[INFO] Agentes: carregados de agents/claude-agents.json"
fi

# Mostrar STATUS.md se existir
if [ -f "$PROJECT_DIR/STATUS.md" ]; then
    echo "[INFO] STATUS.md encontrado — Claude lerá ao iniciar"
fi

echo ""
echo "Iniciando Claude Code CLI..."
echo "  Modelo: $MODEL | Effort: $EFFORT | Modo: $MODE"
echo ""

# Iniciar sessão
claude \
    --system-prompt-file "$SYSTEM_PROMPT_FILE" \
    --model "$MODEL" \
    --effort "$EFFORT" \
    --permission-mode auto \
    $AGENTS_FLAG
