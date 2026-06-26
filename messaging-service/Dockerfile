# =============================================================================
# MedNova AI — messaging-service
# Build : docker compose build messaging-service
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
COPY messaging-service messaging-service

RUN mvn -pl "messaging-service" -am package -DskipTests -B -q \
    || (echo "Maven retry after network error..." && sleep 10 && mvn -pl "messaging-service" -am package -DskipTests -B -q)

FROM eclipse-temurin:21-jre-alpine AS runtime

WORKDIR /app

RUN apk add --no-cache wget \
    && addgroup -S mednova && adduser -S mednova -G mednova

USER mednova

COPY --from=build /app/messaging-service/target/messaging-service-*.jar app.jar

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
