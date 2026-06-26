package com.mednova.ai.infrastructure.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "mednova.ai.risk")
@Getter
@Setter
public class RiskThresholdProperties {

    private int highThreshold = 60;
    private int criticalThreshold = 80;
}
