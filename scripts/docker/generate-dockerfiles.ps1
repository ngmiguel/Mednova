# Génère un Dockerfile par microservice (contexte de build = racine du dépôt)
param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
)

$modules = @(
    "auth-service",
    "patient-service",
    "doctor-service",
    "appointment-service",
    "monitoring-service",
    "ai-prediction-service",
    "notification-service",
    "audit-service",
    "api-gateway"
)

$template = @'
# =============================================================================
# MedNova AI — __MODULE__
# Build : docker compose build __MODULE__
# Contexte : racine du dépôt (..)
# =============================================================================

FROM maven:3.9-eclipse-temurin-21-alpine AS build

WORKDIR /app

COPY pom.xml .
COPY .mvn .mvn
COPY common-lib common-lib
COPY api-gateway api-gateway
COPY auth-service auth-service
COPY patient-service patient-service
COPY doctor-service doctor-service
COPY appointment-service appointment-service
COPY monitoring-service monitoring-service
COPY ai-prediction-service ai-prediction-service
COPY notification-service notification-service
COPY audit-service audit-service

RUN mvn -pl "__MODULE__" -am package -DskipTests -B -q \
    || (echo "Maven retry after network error..." && sleep 10 && mvn -pl "__MODULE__" -am package -DskipTests -B -q)

FROM eclipse-temurin:21-jre-alpine AS runtime

WORKDIR /app

RUN apk add --no-cache wget \
    && addgroup -S mednova && adduser -S mednova -G mednova

USER mednova

COPY --from=build /app/__MODULE__/target/__MODULE__-*.jar app.jar

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
'@

foreach ($module in $modules) {
    $content = $template.Replace("__MODULE__", $module)
    $path = Join-Path $Root "$module/Dockerfile"
    Set-Content -Path $path -Value $content -Encoding UTF8
    Write-Host "Generated $path"
}
