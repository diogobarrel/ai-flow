# claude-start.ps1 — Inicia sessão Claude Code otimizada (Windows)
#
# Uso:
#   .\scripts\claude-start.ps1                    # sessão de implementação
#   .\scripts\claude-start.ps1 refinement         # agente de refinamento
#   .\scripts\claude-start.ps1 review             # revisão de código
#   .\scripts\claude-start.ps1 debug              # debugging

param(
    [string]$Mode = "impl",
    [string]$Model = "sonnet",
    [string]$Effort = "high"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

# Verificar se claude está instalado
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "[FAIL] Claude Code CLI não encontrado" -ForegroundColor Red
    Write-Host "  Instale com: npm install -g @anthropic-ai/claude-code"
    exit 1
}

# Selecionar system prompt por modo
switch ($Mode) {
    { $_ -in "refinement", "refine", "r" } {
        $SystemPromptFile = Join-Path $ProjectDir "prompts\refinement-agent.md"
        Write-Host "[INFO] Modo: Refinamento de demanda" -ForegroundColor Cyan
        Write-Host "[INFO] Modelo: claude-sonnet (recomendado para refinamento)" -ForegroundColor Cyan
    }
    { $_ -in "review", "rev" } {
        $SystemPromptFile = Join-Path $ProjectDir "prompts\templates\PROMPT.md"
        $Model = "haiku"
        Write-Host "[INFO] Modo: Code review (Haiku — custo otimizado)" -ForegroundColor Cyan
    }
    { $_ -in "debug", "d" } {
        $SystemPromptFile = Join-Path $ProjectDir "prompts\templates\PROMPT.md"
        Write-Host "[INFO] Modo: Debugging" -ForegroundColor Cyan
    }
    default {
        $ProjectPrompt = Join-Path $ProjectDir "PROMPT.md"
        if (Test-Path $ProjectPrompt) {
            $SystemPromptFile = $ProjectPrompt
            Write-Host "[INFO] Modo: Implementação (usando PROMPT.md do projeto)" -ForegroundColor Cyan
        } else {
            $SystemPromptFile = Join-Path $ProjectDir "prompts\templates\PROMPT.md"
            Write-Host "[WARN] PROMPT.md não encontrado — usando template" -ForegroundColor Yellow
            Write-Host "[WARN] Execute o refinement agent primeiro" -ForegroundColor Yellow
        }
    }
}

# Verificar agentes config
$AgentsFlag = @()
$UserAgents = "$env:USERPROFILE\.claude\agents.json"
$ProjectAgents = Join-Path $ProjectDir "agents\claude-agents.json"

if (Test-Path $UserAgents) {
    Write-Host "[INFO] Agentes: carregados de ~/.claude/agents.json" -ForegroundColor Cyan
} elseif (Test-Path $ProjectAgents) {
    $AgentsFlag = @("--agents", $ProjectAgents)
    Write-Host "[INFO] Agentes: carregados de agents/claude-agents.json" -ForegroundColor Cyan
}

# Verificar STATUS.md
$StatusFile = Join-Path $ProjectDir "STATUS.md"
if (Test-Path $StatusFile) {
    Write-Host "[INFO] STATUS.md encontrado — Claude lerá ao iniciar" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Iniciando Claude Code CLI..."
Write-Host "  Modelo: $Model | Effort: $Effort | Modo: $Mode"
Write-Host ""

# Iniciar sessão
$ClaudeArgs = @(
    "--system-prompt-file", $SystemPromptFile,
    "--model", $Model,
    "--effort", $Effort,
    "--permission-mode", "auto"
) + $AgentsFlag

& claude @ClaudeArgs
