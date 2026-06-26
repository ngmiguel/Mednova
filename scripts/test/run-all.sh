#!/usr/bin/env bash
# Exécute tous les tests unitaires par module + build
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

MODULES=(
  common-lib
  api-gateway
  auth-service
  patient-service
  doctor-service
  appointment-service
  monitoring-service
  ai-prediction-service
  notification-service
  audit-service
  messaging-service
)

echo "=========================================="
echo " MedNova AI — Suite de tests complète"
echo "=========================================="

"$SCRIPT_DIR/test-build.sh"
echo ""

for module in "${MODULES[@]}"; do
  "$SCRIPT_DIR/test-module.sh" "$module"
  echo ""
done

echo "=========================================="
echo " Tous les tests sont passés (${#MODULES[@]} modules)."
echo "=========================================="
