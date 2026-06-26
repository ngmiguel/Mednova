#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo ">>> Tests: notification-service (handler Kafka)"
mvn -B -pl notification-service -am test -Dtest=DomainEventHandlerTest -Dsurefire.failIfNoSpecifiedTests=false
