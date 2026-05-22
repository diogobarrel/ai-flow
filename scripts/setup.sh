#!/usr/bin/env bash
# setup.sh — Setup inicial do ai-dev-flow (Unix/Mac)
# Uso: chmod +x scripts/setup.sh && ./scripts/setup.sh

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

echo ""
echo "╔══════════════════════════════════╗"
echo "║     ai-dev-flow — Setup          ║"
echo "╚══════════════════════════════════╝"
echo ""

# ── 1. Verificar Node.js ──────────────────────────────────────────
info "Verificando Node.js..."
if ! command -v node &> /dev/null; then
    fail "Node.js não encontrado. Instale em: https://nodejs.org (v18+)"
fi
NODE_VERSION=$(node --version | cut -d. -f1 | tr -d 'v')
if [ "$NODE_VERSION" -lt 18 ]; then
    fail "Node.js v18+ necessário. Versão atual: $(node --version)"
fi
ok "Node.js $(node --version)"

# ── 2. Instalar Claude Code CLI ───────────────────────────────────
info "Verificando Claude Code CLI..."
if ! command -v claude &> /dev/null; then
    warn "Claude Code CLI não encontrado. Instalando..."
    npm install -g @anthropic-ai/claude-code
    ok "Claude Code CLI instalado"
else
    ok "Claude Code CLI $(claude --version 2>/dev/null || echo 'instalado')"
fi

# ── 3. Instalar Gemini CLI ────────────────────────────────────────
info "Verificando Gemini CLI..."
if ! command -v gemini &> /dev/null; then
    warn "Gemini CLI não encontrado. Instalando..."
    npm install -g @google/gemini-cli
    ok "Gemini CLI instalado"
else
    ok "Gemini CLI instalado"
fi

# ── 4. Configurar Claude ──────────────────────────────────────────
info "Configurando Claude Code..."
CLAUDE_CONFIG_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_CONFIG_DIR"

if [ ! -f "$CLAUDE_CONFIG_DIR/CLAUDE.md" ]; then
    # Extrai o prompt do arquivo (entre os backticks do bloco de código)
    sed -n '/^```$/,/^```$/p' prompts/system-prompt-claude.md | \
        grep -v '^```' > "$CLAUDE_CONFIG_DIR/CLAUDE.md"
    ok "CLAUDE.md criado em $CLAUDE_CONFIG_DIR"
else
    warn "CLAUDE.md já existe em $CLAUDE_CONFIG_DIR — não sobrescrevendo"
fi

# Copiar agents config
if [ ! -f "$CLAUDE_CONFIG_DIR/agents.json" ]; then
    cp agents/claude-agents.json "$CLAUDE_CONFIG_DIR/agents.json"
    ok "agents.json copiado para $CLAUDE_CONFIG_DIR"
else
    warn "agents.json já existe em $CLAUDE_CONFIG_DIR — não sobrescrevendo"
fi

# ── 5. Configurar Gemini ──────────────────────────────────────────
info "Configurando Gemini CLI..."
GEMINI_CONFIG_DIR="$HOME/.gemini"
mkdir -p "$GEMINI_CONFIG_DIR"

if [ ! -f "$GEMINI_CONFIG_DIR/settings.json" ]; then
    cp config/gemini-settings.json "$GEMINI_CONFIG_DIR/settings.json"
    ok "settings.json copiado para $GEMINI_CONFIG_DIR"
else
    warn "settings.json já existe em $GEMINI_CONFIG_DIR — não sobrescrevendo"
fi

# ── 6. Criar .env se não existir ─────────────────────────────────
if [ ! -f ".env" ]; then
    cp config/.env.example .env
    ok ".env criado a partir de .env.example"
    warn "ATENÇÃO: Edite .env com suas API keys antes de usar"
else
    warn ".env já existe — não sobrescrevendo"
fi

# ── 7. Tornar scripts executáveis ────────────────────────────────
chmod +x scripts/*.sh
ok "Scripts tornados executáveis"

# ── 8. Autenticação (CLIs nativos — sem API key necessária) ───────
echo ""
info "Verificando autenticação..."
info "Claude Code e Gemini CLI usam login por conta — sem API key necessária"
info ""
info "Se ainda não autenticou:"
warn "  Claude: execute 'claude' e siga o fluxo de login"
warn "  Gemini: execute 'gemini auth login' para autenticar com Google"

# ── 9. Resumo ─────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║                    Setup completo!                   ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║                                                      ║"
echo "║  Próximos passos:                                    ║"
echo "║                                                      ║"
echo "║  1. Edite .env com suas API keys                     ║"
echo "║  2. Refine sua demanda:                              ║"
echo "║     ./scripts/claude-start.sh refinement            ║"
echo "║                                                      ║"
echo "║  3. Inicie a implementação:                          ║"
echo "║     ./scripts/claude-start.sh                       ║"
echo "║     ./scripts/gemini-start.sh                       ║"
echo "║                                                      ║"
echo "║  Docs: docs/workflow-guide.md                        ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
