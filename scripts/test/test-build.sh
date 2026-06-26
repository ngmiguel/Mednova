#!/usr/bin/env bash
# Compile tous les modules sans tests ni repackage Spring Boot (évite les JAR verrouillés en local)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo ">>> Build: mvn package -DskipTests -Dspring-boot.repackage.skip=true"
mvn -B package -DskipTests -Dspring-boot.repackage.skip=true
