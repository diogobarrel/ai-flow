# gemini-start.ps1 — Inicia sessão Gemini CLI otimizada (Windows)
#
# Uso:
#   .\scripts\gemini-start.ps1                    # geral
#   .\scripts\gemini-start.ps1 analyze            # análise de codebase
#   .\scripts\gemini-start.ps1 research           # pesquisa com search grounding
#   .\scripts\gemini-start.ps1 visual             # análise de imagens/PDFs
#   .\scripts\gemini-start.ps1 refinement         # refinamento de demanda
#   .\scripts\gemini-start.ps1 budget             # tarefas simples/baratas

param(
    [string]$Mode = "general",
    [string]$Model = ""
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

# Verificar se gemini está instalado
if (-not (Get-Command gemini -ErrorAction SilentlyContinue)) {
    Write-Host "[FAIL] Gemini CLI não encontrado" -ForegroundColor Red
    Write-Host "  Instale com: npm install -g @google/gemini-cli"
    Write-Host "  Depois autentique com: gemini auth login"
    exit 1
}

# Compatibilidade entre GEMINI_API_KEY e GOOGLE_API_KEY
if ($env:GEMINI_API_KEY -and -not $env:GOOGLE_API_KEY) {
    $env:GOOGLE_API_KEY = $env:GEMINI_API_KEY
}

# Selecionar modelo e system prompt por modo
$ExtraFlags = @()
switch ($Mode) {
    { $_ -in "analyze", "analysis", "a" } {
        if (-not $Model) { $Model = "gemini-2.5-pro" }
        $SystemPromptFile = Join-Path $ProjectDir "prompts\system-prompt-gemini.md"
        $ExtraFlags = @("--all-files")
        Write-Host "[INFO] Modo: Análise de codebase" -ForegroundColor Cyan
        Write-Host "[INFO] Modelo: $Model (context window 2M tokens)" -ForegroundColor Cyan
    }
    { $_ -in "research", "search", "s" } {
        if (-not $Model) { $Model = "gemini-2.5-flash" }
        $SystemPromptFile = Join-Path $ProjectDir "prompts\system-prompt-gemini.md"
        $ExtraFlags = @("--search")
        Write-Host "[INFO] Modo: Pesquisa com search grounding" -ForegroundColor Cyan
        Write-Host "[INFO] Modelo: $Model (otimizado para velocidade + custo)" -ForegroundColor Cyan
    }
    { $_ -in "visual", "image", "v" } {
        if (-not $Model) { $Model = "gemini-2.5-pro" }
        $SystemPromptFile = Join-Path $ProjectDir "prompts\system-prompt-gemini.md"
        Write-Host "[INFO] Modo: Análise visual (imagens/PDFs/screenshots)" -ForegroundColor Cyan
        Write-Host "[INFO] Modelo: $Model (multimodal)" -ForegroundColor Cyan
    }
    { $_ -in "refinement", "refine", "r" } {
        if (-not $Model) { $Model = "gemini-2.5-pro" }
        $SystemPromptFile = Join-Path $ProjectDir "prompts\refinement-agent.md"
        Write-Host "[INFO] Modo: Refinamento de demanda" -ForegroundColor Cyan
        Write-Host "[INFO] Modelo: $Model (raciocínio profundo)" -ForegroundColor Cyan
    }
    { $_ -in "budget", "b" } {
        if (-not $Model) { $Model = "gemini-2.0-flash" }
        $SystemPromptFile = Join-Path $ProjectDir "prompts\system-prompt-gemini.md"
        Write-Host "[INFO] Modo: Budget (tarefas simples)" -ForegroundColor Cyan
        Write-Host "[INFO] Modelo: $Model (máxima eficiência de custo)" -ForegroundColor Cyan
    }
    default {
        if (-not $Model) { $Model = "gemini-2.5-flash" }
        $SystemPromptFile = Join-Path $ProjectDir "prompts\system-prompt-gemini.md"
        Write-Host "[INFO] Modo: Geral" -ForegroundColor Cyan
        Write-Host "[INFO] Modelo: $Model" -ForegroundColor Cyan
    }
}

# Verificar STATUS.md
$StatusFile = Join-Path $ProjectDir "STATUS.md"
if (Test-Path $StatusFile) {
    Write-Host "[INFO] STATUS.md encontrado — será incluído no contexto" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Iniciando Gemini CLI..."
Write-Host "  Modelo: $Model | Modo: $Mode"
Write-Host ""

# Iniciar sessão Gemini
$GeminiArgs = @(
    "--model", $Model,
    "--system-prompt-file", $SystemPromptFile
) + $ExtraFlags

& gemini @GeminiArgs
