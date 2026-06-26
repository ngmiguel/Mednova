package com.mednova.ai;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@org.springframework.boot.context.properties.EnableConfigurationProperties(
        com.mednova.ai.infrastructure.config.RiskThresholdProperties.class
)
public class AiPredictionServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(AiPredictionServiceApplication.class, args);
    }
}
