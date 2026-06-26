#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo ">>> Tests: monitoring-service (détection anomalies)"
mvn -B -pl monitoring-service -am test -Dtest=AnomalyDetectionServiceTest -Dsurefire.failIfNoSpecifiedTests=false
