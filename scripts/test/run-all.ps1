# Execute tous les tests unitaires — tous les modules
$ErrorActionPreference = "Stop"

$modules = @(
    "common-lib",
    "api-gateway",
    "auth-service",
    "patient-service",
    "doctor-service",
    "appointment-service",
    "monitoring-service",
    "ai-prediction-service",
    "notification-service",
    "audit-service",
    "messaging-service"
)

& "$PSScriptRoot\test-build.ps1"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

foreach ($module in $modules) {
    & "$PSScriptRoot\test-module.ps1" -Module $module
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ECHEC: $module (code $LASTEXITCODE)" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

Write-Host ""
Write-Host "Tous les tests sont passes ($($modules.Count) modules)." -ForegroundColor Green
