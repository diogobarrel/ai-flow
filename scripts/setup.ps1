# setup.ps1 — Setup inicial do ai-dev-flow (Windows)
# Uso: .\scripts\setup.ps1

$ErrorActionPreference = "Stop"

function Write-Info  { Write-Host "[INFO] $args" -ForegroundColor Cyan }
function Write-Ok    { Write-Host "[OK]   $args" -ForegroundColor Green }
function Write-Warn  { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Fail  { Write-Host "[FAIL] $args" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "╔══════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║     ai-dev-flow — Setup          ║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# ── 1. Verificar Node.js ──────────────────────────────────────────
Write-Info "Verificando Node.js..."
try {
    $nodeVersion = (node --version) -replace 'v', '' -split '\.' | Select-Object -First 1
    if ([int]$nodeVersion -lt 18) {
        Write-Fail "Node.js v18+ necessário. Atual: $(node --version)"
    }
    Write-Ok "Node.js $(node --version)"
} catch {
    Write-Fail "Node.js não encontrado. Instale em: https://nodejs.org (v18+)"
}

# ── 2. Instalar Claude Code CLI ───────────────────────────────────
Write-Info "Verificando Claude Code CLI..."
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Warn "Claude Code CLI não encontrado. Instalando..."
    npm install -g @anthropic-ai/claude-code
    Write-Ok "Claude Code CLI instalado"
} else {
    Write-Ok "Claude Code CLI instalado"
}

# ── 3. Instalar Gemini CLI ────────────────────────────────────────
Write-Info "Verificando Gemini CLI..."
if (-not (Get-Command gemini -ErrorAction SilentlyContinue)) {
    Write-Warn "Gemini CLI não encontrado. Instalando..."
    npm install -g @google/gemini-cli
    Write-Ok "Gemini CLI instalado"
} else {
    Write-Ok "Gemini CLI instalado"
}

# ── 4. Configurar Claude ──────────────────────────────────────────
Write-Info "Configurando Claude Code..."
$claudeConfigDir = "$env:USERPROFILE\.claude"
New-Item -ItemType Directory -Force -Path $claudeConfigDir | Out-Null

if (-not (Test-Path "$claudeConfigDir\CLAUDE.md")) {
    Copy-Item "prompts\system-prompt-claude.md" "$claudeConfigDir\CLAUDE.md"
    Write-Ok "CLAUDE.md criado em $claudeConfigDir"
} else {
    Write-Warn "CLAUDE.md já existe em $claudeConfigDir — não sobrescrevendo"
}

if (-not (Test-Path "$claudeConfigDir\agents.json")) {
    Copy-Item "agents\claude-agents.json" "$claudeConfigDir\agents.json"
    Write-Ok "agents.json copiado para $claudeConfigDir"
} else {
    Write-Warn "agents.json já existe em $claudeConfigDir — não sobrescrevendo"
}

# ── 5. Configurar Gemini ──────────────────────────────────────────
Write-Info "Configurando Gemini CLI..."
$geminiConfigDir = "$env:USERPROFILE\.gemini"
New-Item -ItemType Directory -Force -Path $geminiConfigDir | Out-Null

if (-not (Test-Path "$geminiConfigDir\settings.json")) {
    Copy-Item "config\gemini-settings.json" "$geminiConfigDir\settings.json"
    Write-Ok "settings.json copiado para $geminiConfigDir"
} else {
    Write-Warn "settings.json já existe em $geminiConfigDir — não sobrescrevendo"
}

# ── 6. Criar .env se não existir ─────────────────────────────────
if (-not (Test-Path ".env")) {
    Copy-Item "config\.env.example" ".env"
    Write-Ok ".env criado a partir de .env.example"
    Write-Warn "ATENÇÃO: Edite .env com suas API keys antes de usar"
} else {
    Write-Warn ".env já existe — não sobrescrevendo"
}

# ── 7. Verificar API keys ─────────────────────────────────────────
Write-Host ""
Write-Info "Verificando API keys..."

if (-not $env:ANTHROPIC_API_KEY) {
    Write-Warn "ANTHROPIC_API_KEY não definida — necessária para Claude"
    Write-Warn "  Defina em .env ou como variável de ambiente"
}

if (-not $env:GEMINI_API_KEY -and -not $env:GOOGLE_API_KEY) {
    Write-Warn "GEMINI_API_KEY / GOOGLE_API_KEY não definida — necessária para Gemini"
    Write-Warn "  Obtenha em: https://aistudio.google.com/app/apikey"
}

# ── 8. Resumo ─────────────────────────────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    Setup completo!                   ║" -ForegroundColor Green
Write-Host "╠══════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║                                                      ║" -ForegroundColor Green
Write-Host "║  Próximos passos:                                    ║" -ForegroundColor Green
Write-Host "║                                                      ║" -ForegroundColor Green
Write-Host "║  1. Edite .env com suas API keys                     ║" -ForegroundColor Green
Write-Host "║  2. Refine sua demanda:                              ║" -ForegroundColor Green
Write-Host "║     .\scripts\claude-start.ps1 refinement           ║" -ForegroundColor Green
Write-Host "║                                                      ║" -ForegroundColor Green
Write-Host "║  3. Inicie a implementação:                          ║" -ForegroundColor Green
Write-Host "║     .\scripts\claude-start.ps1                      ║" -ForegroundColor Green
Write-Host "║     .\scripts\gemini-start.ps1                      ║" -ForegroundColor Green
Write-Host "║                                                      ║" -ForegroundColor Green
Write-Host "║  Docs: docs\workflow-guide.md                        ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
