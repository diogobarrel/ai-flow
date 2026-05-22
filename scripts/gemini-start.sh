#!/usr/bin/env bash
# gemini-start.sh — Inicia sessão Gemini CLI otimizada
#
# Uso:
#   ./scripts/gemini-start.sh                    # análise / pesquisa geral
#   ./scripts/gemini-start.sh analyze            # análise de codebase
#   ./scripts/gemini-start.sh research           # pesquisa com search grounding
#   ./scripts/gemini-start.sh visual             # análise de imagens/PDFs
#   ./scripts/gemini-start.sh refinement         # refinamento de demanda

set -e

MODE="${1:-general}"
MODEL="${2:-}"  # Auto-seleção por modo se não especificado

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Verificar se gemini está instalado
if ! command -v gemini &> /dev/null; then
    echo "[FAIL] Gemini CLI não encontrado"
    echo "  Instale com: npm install -g @google/gemini-cli"
    echo "  Depois autentique com: gemini auth login"
    exit 1
fi

# Selecionar modelo e system prompt por modo
case "$MODE" in
    analyze|analysis|a)
        [ -z "$MODEL" ] && MODEL="gemini-2.5-pro"
        SYSTEM_PROMPT_FILE="$PROJECT_DIR/prompts/system-prompt-gemini.md"
        EXTRA_FLAGS="--all-files"  # Carrega todos os arquivos do diretório
        echo "[INFO] Modo: Análise de codebase"
        echo "[INFO] Modelo: $MODEL (context window 2M tokens)"
        echo "[INFO] Carregando arquivos do projeto..."
        ;;
    research|search|s)
        [ -z "$MODEL" ] && MODEL="gemini-2.5-flash"
        SYSTEM_PROMPT_FILE="$PROJECT_DIR/prompts/system-prompt-gemini.md"
        EXTRA_FLAGS="--search"  # Habilita search grounding
        echo "[INFO] Modo: Pesquisa com search grounding"
        echo "[INFO] Modelo: $MODEL (otimizado para velocidade + custo)"
        ;;
    visual|image|v)
        [ -z "$MODEL" ] && MODEL="gemini-2.5-pro"
        SYSTEM_PROMPT_FILE="$PROJECT_DIR/prompts/system-prompt-gemini.md"
        echo "[INFO] Modo: Análise visual (imagens/PDFs/screenshots)"
        echo "[INFO] Modelo: $MODEL (multimodal)"
        ;;
    refinement|refine|r)
        [ -z "$MODEL" ] && MODEL="gemini-2.5-pro"
        SYSTEM_PROMPT_FILE="$PROJECT_DIR/prompts/refinement-agent.md"
        echo "[INFO] Modo: Refinamento de demanda"
        echo "[INFO] Modelo: $MODEL (raciocínio profundo)"
        ;;
    budget|b)
        [ -z "$MODEL" ] && MODEL="gemini-2.0-flash"
        SYSTEM_PROMPT_FILE="$PROJECT_DIR/prompts/system-prompt-gemini.md"
        echo "[INFO] Modo: Budget (tarefas simples)"
        echo "[INFO] Modelo: $MODEL (máxima eficiência de custo)"
        ;;
    general|*)
        [ -z "$MODEL" ] && MODEL="gemini-2.5-flash"
        SYSTEM_PROMPT_FILE="$PROJECT_DIR/prompts/system-prompt-gemini.md"
        echo "[INFO] Modo: Geral"
        echo "[INFO] Modelo: $MODEL"
        ;;
esac

# Verificar STATUS.md
if [ -f "$PROJECT_DIR/STATUS.md" ]; then
    echo "[INFO] STATUS.md encontrado — será incluído no contexto"
fi

echo ""
echo "Iniciando Gemini CLI..."
echo "  Modelo: $MODEL | Modo: $MODE"
echo ""

# Iniciar sessão Gemini
# Nota: flags variam conforme versão do Gemini CLI
gemini \
    --model "$MODEL" \
    --system-prompt-file "$SYSTEM_PROMPT_FILE" \
    ${EXTRA_FLAGS:-}
