# Verifie que la connexion demo fonctionne via la gateway
param(
    [string]$BaseUrl = "http://localhost:8080",
    [string]$Email = "admin@mednova.ai",
    [string]$Password = "password123"
)

$ErrorActionPreference = "Stop"

Write-Host "Test login $Email ..." -ForegroundColor Cyan

$body = @{ email = $Email; password = $Password } | ConvertTo-Json
$login = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/login" -Method POST -ContentType "application/json" -Body $body

if (-not $login.data.accessToken) {
    if ($login.data.requiresTwoFactor) {
        throw "2FA active sur le compte demo — relancez avec reset volumes: .\scripts\docker\up.ps1 -ResetVolumes -Build"
    }
    throw "Login echoue : pas de token dans la reponse"
}

$headers = @{ Authorization = "Bearer $($login.data.accessToken)" }
$profile = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/me" -Method GET -Headers $headers

Write-Host "  Login OK — profil: $($profile.data.email) roles: $($profile.data.roles -join ', ')" -ForegroundColor Green
