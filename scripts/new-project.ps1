# new-project.ps1 — Cria um novo projeto a partir do workflow template (Windows)
#
# Uso:
#   .\scripts\new-project.ps1 <nome-do-projeto> [diretório-destino]
#
# Exemplos:
#   .\scripts\new-project.ps1 meu-app
#   .\scripts\new-project.ps1 estudo-rust C:\projects
#   .\scripts\new-project.ps1 api-gateway D:\dev\projetos

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    [string]$DestBase = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Cyan }
function Write-Ok   { Write-Host "[OK]   $args" -ForegroundColor Green }
function Write-Warn { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Fail { Write-Host "[FAIL] $args" -ForegroundColor Red; exit 1 }

$DestDir     = Join-Path $DestBase $ProjectName
$TemplateDir = Split-Path -Parent $PSScriptRoot

Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║     ai-dev-flow — Novo Projeto           ║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""
Write-Info "Projeto:  $ProjectName"
Write-Info "Destino:  $DestDir"
Write-Info "Template: $TemplateDir"
Write-Host ""

if (Test-Path $DestDir) { Write-Fail "Diretório já existe: $DestDir" }

# Criar estrutura do projeto copiando o template
# Excluir: .git, arquivos de projeto específicos, .env
$Excludes = @('.git', 'ARCHITECTURE.md', 'PROMPT.md', 'STATUS.md', '.env', 'node_modules')

New-Item -ItemType Directory -Path $DestDir | Out-Null

Get-ChildItem -Path $TemplateDir -Recurse | ForEach-Object {
    $RelPath = $_.FullName.Substring($TemplateDir.Length + 1)
    $Parts   = $RelPath -split '\\'

    # Pular exclusões
    foreach ($ex in $Excludes) {
        if ($Parts[0] -eq $ex -or $_.Name -eq $ex) { return }
    }

    $Dest = Join-Path $DestDir $RelPath
    if ($_.PSIsContainer) {
        New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    } else {
        Copy-Item -Path $_.FullName -Destination $Dest -Force
    }
}

# Copiar templates de projeto como arquivos raiz
Copy-Item (Join-Path $TemplateDir "prompts\templates\ARCHITECTURE.md") (Join-Path $DestDir "ARCHITECTURE.md")
Copy-Item (Join-Path $TemplateDir "prompts\templates\PROMPT.md")       (Join-Path $DestDir "PROMPT.md")
Copy-Item (Join-Path $TemplateDir "prompts\templates\STATUS.md")       (Join-Path $DestDir "STATUS.md")
Copy-Item (Join-Path $TemplateDir "config\.env.example")               (Join-Path $DestDir ".env")

# Substituir placeholder pelo nome do projeto
foreach ($File in @("ARCHITECTURE.md", "PROMPT.md", "STATUS.md")) {
    $Path = Join-Path $DestDir $File
    (Get-Content $Path) -replace '\[Nome do Sistema\]', $ProjectName | Set-Content $Path
}

# Inicializar git
Set-Location $DestDir
git init -q
git add .
git commit -q -m "Initial: ai-dev-flow workflow scaffold"

Write-Ok "Projeto '$ProjectName' criado em $DestDir"
Write-Host ""
Write-Host "Próximos passos:"
Write-Host ""
Write-Host "  cd $DestDir"
Write-Host ""
Write-Host "  # Rodar refinement agent para gerar ARCHITECTURE.md + PROMPT.md"
Write-Host "  .\scripts\claude-start.ps1 refinement"
Write-Host ""
Write-Host "  # Ou com Gemini:"
Write-Host "  .\scripts\gemini-start.ps1 refinement"
Write-Host ""
