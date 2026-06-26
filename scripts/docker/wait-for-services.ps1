# Attend que auth-service et api-gateway soient healthy
param(
    [int]$MaxAttempts = 60,
    [int]$DelaySeconds = 10
)

$ErrorActionPreference = "Stop"

function Wait-ContainerHealthy {
    param([string]$Name)
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        $status = docker inspect --format='{{.State.Health.Status}}' $Name 2>$null
        if ($status -eq "healthy") {
            Write-Host "  OK $Name" -ForegroundColor Green
            return $true
        }
        if (-not $status) {
            $running = docker inspect --format='{{.State.Running}}' $Name 2>$null
            if ($running -eq "true" -and $Name -ne "mednova-gateway" -and $Name -ne "mednova-auth") {
                Write-Host "  OK $Name (sans healthcheck)" -ForegroundColor Green
                return $true
            }
        }
        Write-Host "  ... $Name ($status) tentative $i/$MaxAttempts" -ForegroundColor Gray
        Start-Sleep -Seconds $DelaySeconds
    }
    throw "Timeout en attendant $Name"
}

Wait-ContainerHealthy "mednova-postgres" | Out-Null
Wait-ContainerHealthy "mednova-auth"
Wait-ContainerHealthy "mednova-gateway"
