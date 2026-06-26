$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Maven = if (Test-Path "C:\Program Files\JetBrains\IntelliJ IDEA 2023.3.4\plugins\maven\lib\maven3\bin\mvn.cmd") {
    "C:\Program Files\JetBrains\IntelliJ IDEA 2023.3.4\plugins\maven\lib\maven3\bin\mvn.cmd"
} else { "mvn" }
Write-Host ">>> Tests: common-lib (evenements Kafka)" -ForegroundColor Yellow
& $Maven -f "$Root\pom.xml" -B -pl common-lib test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
