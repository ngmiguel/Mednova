# Installe le NDK Android manuellement (contourne sdkmanager si le reseau coupe le telechargement).
# Usage: .\scripts\install-ndk.ps1
# Prerequis: ~800 Mo libres, connexion stable, desactiver antivirus temporairement si echec.

$ErrorActionPreference = "Stop"

$sdk = "$env:LOCALAPPDATA\Android\Sdk"
$ndkVersion = "27.0.12077973"
$ndkDir = Join-Path $sdk "ndk\$ndkVersion"
$zipUrl = "https://dl.google.com/android/repository/android-ndk-r27-windows.zip"
$zipPath = Join-Path $env:TEMP "android-ndk-r27-windows.zip"
$extractRoot = Join-Path $env:TEMP "android-ndk-r27-extract"

Write-Host "SDK: $sdk"
Write-Host "NDK cible: $ndkDir"

# 1. Nettoyer caches SDK corrompus (cause frequente des echecs)
foreach ($folder in @(".temp", ".downloadIntermediates")) {
    $p = Join-Path $sdk $folder
    if (Test-Path $p) {
        Write-Host "Suppression $p ..."
        Remove-Item -Recurse -Force $p -ErrorAction SilentlyContinue
    }
}

# 2. Supprimer NDK incomplets
Get-ChildItem (Join-Path $sdk "ndk") -ErrorAction SilentlyContinue | ForEach-Object {
    $sp = Join-Path $_.FullName "source.properties"
    if (-not (Test-Path $sp)) {
        Write-Host "Suppression NDK incomplet: $($_.Name)"
        Remove-Item -Recurse -Force $_.FullName -ErrorAction SilentlyContinue
    }
}

# 3. Telecharger (~745 Mo)
if (-not (Test-Path $zipPath) -or (Get-Item $zipPath).Length -lt 700000000) {
    Write-Host "Telechargement NDK (plusieurs minutes)..."
    curl.exe -L --retry 5 --retry-delay 5 -o $zipPath $zipUrl
    if ($LASTEXITCODE -ne 0) { throw "Echec telechargement curl (code $LASTEXITCODE)" }
} else {
    Write-Host "ZIP deja present: $zipPath"
}

# 4. Extraire
if (Test-Path $extractRoot) { Remove-Item -Recurse -Force $extractRoot }
Write-Host "Extraction..."
Expand-Archive -Path $zipPath -DestinationPath $extractRoot -Force

$inner = Get-ChildItem $extractRoot -Directory | Select-Object -First 1
if (-not $inner) { throw "Archive NDK invalide" }

if (Test-Path $ndkDir) { Remove-Item -Recurse -Force $ndkDir }
New-Item -ItemType Directory -Path (Split-Path $ndkDir) -Force | Out-Null
Move-Item $inner.FullName $ndkDir

if (-not (Test-Path (Join-Path $ndkDir "source.properties"))) {
    throw "Installation echouee: source.properties absent"
}

Write-Host ""
Write-Host "NDK installe avec succes: $ndkDir"
Write-Host "Relancez: flutter clean && flutter run --flavor dev"
