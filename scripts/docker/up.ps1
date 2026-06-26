# Lance la stack complète MedNova (infra + microservices + UI)
param(
    [switch]$Build,
    [switch]$ResetVolumes
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "../..")
Push-Location $Root

try {
    if ($ResetVolumes) {
        Write-Host "Suppression des volumes MedNova..." -ForegroundColor Yellow
        docker compose down -v --remove-orphans 2>$null
    }

    $args = @("compose", "up", "-d")
    if ($Build) { $args += "--build" }

    Write-Host "Demarrage MedNova AI..." -ForegroundColor Cyan
    docker @args

    Write-Host "`nAttente des services (auth + gateway)..." -ForegroundColor Yellow
    & "$PSScriptRoot/wait-for-services.ps1"

    Write-Host "`nVerification connexion demo..." -ForegroundColor Yellow
    & "$PSScriptRoot/verify-login.ps1"

    Write-Host "`nStack prete :" -ForegroundColor Green
    Write-Host "  UI       -> http://localhost:4200"
    Write-Host "  Gateway  -> http://localhost:8080"
    Write-Host "  Postgres -> localhost:5433"
    Write-Host "`nComptes demo : admin@mednova.ai / password123"
}
finally {
    Pop-Location
}
