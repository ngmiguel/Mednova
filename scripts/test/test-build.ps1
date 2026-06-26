$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location $Root
$Maven = if (Test-Path "C:\Program Files\JetBrains\IntelliJ IDEA 2023.3.4\plugins\maven\lib\maven3\bin\mvn.cmd") {
    "C:\Program Files\JetBrains\IntelliJ IDEA 2023.3.4\plugins\maven\lib\maven3\bin\mvn.cmd"
} else { "mvn" }
Write-Host ">>> Build: mvn package -DskipTests -Dspring-boot.repackage.skip=true" -ForegroundColor Yellow
& $Maven -f "$Root\pom.xml" -B package -DskipTests "-Dspring-boot.repackage.skip=true"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
