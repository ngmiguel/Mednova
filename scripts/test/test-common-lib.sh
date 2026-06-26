#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo ">>> Tests: common-lib"
mvn -B -pl common-lib test
