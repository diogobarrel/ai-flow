#!/usr/bin/env bash
# new-project.sh — Cria um novo projeto a partir do workflow template
#
# Uso:
#   ./scripts/new-project.sh <nome-do-projeto> [diretório-destino]
#
# Exemplos:
#   ./scripts/new-project.sh meu-app
#   ./scripts/new-project.sh estudo-rust ~/projects
#   ./scripts/new-project.sh api-gateway /dev/projetos

set -e

BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

PROJECT_NAME="${1:-}"
DEST_BASE="${2:-$(pwd)/..}"

[ -z "$PROJECT_NAME" ] && fail "Informe o nome do projeto: ./scripts/new-project.sh <nome>"

DEST_DIR="$DEST_BASE/$PROJECT_NAME"
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║     ai-dev-flow — Novo Projeto           ║"
echo "╚══════════════════════════════════════════╝"
echo ""
info "Projeto:  $PROJECT_NAME"
info "Destino:  $DEST_DIR"
info "Template: $TEMPLATE_DIR"
echo ""

# Verificar se destino já existe
[ -d "$DEST_DIR" ] && fail "Diretório já existe: $DEST_DIR"

# Criar diretório do projeto
mkdir -p "$DEST_DIR"

# Copiar estrutura do workflow (exceto arquivos de projeto e .git)
rsync -av --exclude='.git' \
          --exclude='ARCHITECTURE.md' \
          --exclude='PROMPT.md' \
          --exclude='STATUS.md' \
          --exclude='.env' \
          --exclude='node_modules' \
          "$TEMPLATE_DIR/" "$DEST_DIR/" > /dev/null

# Copiar .env.example como .env (sem as keys)
cp "$TEMPLATE_DIR/config/.env.example" "$DEST_DIR/.env"

# Criar ARCHITECTURE.md vazio a partir do template
cp "$TEMPLATE_DIR/prompts/templates/ARCHITECTURE.md" "$DEST_DIR/ARCHITECTURE.md"
cp "$TEMPLATE_DIR/prompts/templates/PROMPT.md" "$DEST_DIR/PROMPT.md"
cp "$TEMPLATE_DIR/prompts/templates/STATUS.md" "$DEST_DIR/STATUS.md"

# Substituir placeholder [Nome do Sistema] pelo nome do projeto
sed -i "s/\[Nome do Sistema\]/$PROJECT_NAME/g" "$DEST_DIR/ARCHITECTURE.md" 2>/dev/null || true
sed -i "s/\[Nome do Sistema\]/$PROJECT_NAME/g" "$DEST_DIR/PROMPT.md" 2>/dev/null || true
sed -i "s/\[Nome do Sistema\]/$PROJECT_NAME/g" "$DEST_DIR/STATUS.md" 2>/dev/null || true

# Inicializar git
cd "$DEST_DIR"
git init -q
git add .
git commit -q -m "Initial: ai-dev-flow workflow scaffold"

ok "Projeto '$PROJECT_NAME' criado em $DEST_DIR"
echo ""
echo "Próximos passos:"
echo ""
echo "  cd $DEST_DIR"
echo ""
echo "  # Rodar refinement agent para gerar ARCHITECTURE.md + PROMPT.md"
echo "  ./scripts/claude-start.sh refinement"
echo ""
echo "  # Ou com Gemini:"
echo "  ./scripts/gemini-start.sh refinement"
echo ""
