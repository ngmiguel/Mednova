#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo ">>> Tests: ai-prediction-service (Health Risk Engine)"
mvn -B -pl ai-prediction-service -am test -Dtest=HealthRiskEngineTest -Dsurefire.failIfNoSpecifiedTests=false
