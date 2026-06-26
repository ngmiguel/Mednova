#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo ">>> Tests: auth-service (TOTP / 2FA)"
mvn -B -pl auth-service -am test -Dtest=TotpServiceTest -Dsurefire.failIfNoSpecifiedTests=false
