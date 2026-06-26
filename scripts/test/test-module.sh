#!/usr/bin/env bash
# Exécute tous les tests d'un module Maven (+ dépendances reactor)
set -euo pipefail
MODULE="${1:?Usage: test-module.sh <module-artifactId>}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo ">>> Tests: ${MODULE} (suite complète)"
mvn -B -pl "${MODULE}" -am test -Dsurefire.failIfNoSpecifiedTests=false
