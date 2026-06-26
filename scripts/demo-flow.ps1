# =============================================================================
# MedNova AI — Script de démonstration du flux complet
# Prérequis : Gateway (8080) + tous les microservices démarrés
# Usage : .\scripts\demo-flow.ps1
# =============================================================================

$ErrorActionPreference = "Stop"
$BaseUrl = "http://localhost:8080"
$PatientId = "70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6"
$PatientUserId = "70f5f2f0-2c86-4a09-b053-ac4b5be3f3b6"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " MedNova AI — Demo flux complet" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Login medecin
Write-Host "`n[1/6] Connexion medecin..." -ForegroundColor Yellow
$login = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/login" -Method POST `
    -ContentType "application/json" `
    -Body '{"email":"dr.smith@mednova.ai","password":"password123"}'
$token = $login.data.accessToken
$headers = @{ Authorization = "Bearer $token" }
Write-Host "  OK - Token obtenu" -ForegroundColor Green

# 2. Vitals critiques
Write-Host "`n[2/6] Enregistrement vitals CRITIQUES..." -ForegroundColor Yellow
$vitalsBody = @{
    patientId       = $PatientId
    patientUserId   = $PatientUserId
    heartRate       = 145
    systolicBp      = 190
    diastolicBp     = 120
    temperature     = 39.5
    oxygenSaturation = 88
} | ConvertTo-Json
$vitals = Invoke-RestMethod -Uri "$BaseUrl/api/v1/monitoring/vitals" -Method POST `
    -ContentType "application/json" -Headers $headers -Body $vitalsBody
Write-Host "  OK - Anomalie: $($vitals.data.anomalyDetected)" -ForegroundColor Green
Write-Host "  Details: $($vitals.data.anomalyDetails)" -ForegroundColor Gray

# 3. Attente Kafka
Write-Host "`n[3/6] Attente propagation Kafka (5s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# 4. Evaluation AI
Write-Host "`n[4/6] Derniere evaluation de risque AI..." -ForegroundColor Yellow
$ai = Invoke-RestMethod -Uri "$BaseUrl/api/v1/ai/patients/$PatientId/risk-assessments/latest" -Headers $headers
Write-Host "  Score: $($ai.data.riskScore) | Niveau: $($ai.data.riskLevel)" -ForegroundColor Green
Write-Host "  $($ai.data.recommendation)" -ForegroundColor Gray

# 5. Notifications staff
Write-Host "`n[5/6] Notifications staff..." -ForegroundColor Yellow
$notifs = Invoke-RestMethod -Uri "$BaseUrl/api/v1/notifications?type=HEALTH_ALERT&size=1" -Headers $headers
if ($notifs.data.totalElements -gt 0) {
    $n = $notifs.data.content[0]
    Write-Host "  OK - [$($n.type)] $($n.title) ($($n.status))" -ForegroundColor Green
} else {
    Write-Host "  Aucune notification HEALTH_ALERT trouvee" -ForegroundColor Red
}

# 6. Audit
Write-Host "`n[6/6] Journal d'audit (admin)..." -ForegroundColor Yellow
$adminLogin = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/login" -Method POST `
    -ContentType "application/json" `
    -Body '{"email":"admin@mednova.ai","password":"password123"}'
$adminHeaders = @{ Authorization = "Bearer $($adminLogin.data.accessToken)" }
$audit = Invoke-RestMethod -Uri "$BaseUrl/api/v1/audit/events?eventType=HEALTH_ALERT_TRIGGERED&size=1" -Headers $adminHeaders
Write-Host "  OK - $($audit.data.totalElements) evenement(s) HEALTH_ALERT_TRIGGERED" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " Demo terminee avec succes!" -ForegroundColor Cyan
Write-Host " Swagger: $BaseUrl/swagger-ui.html" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
