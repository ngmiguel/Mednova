package com.mednova.monitoring.infrastructure.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.math.BigDecimal;

@ConfigurationProperties(prefix = "mednova.monitoring.anomaly")
@Getter
@Setter
public class AnomalyThresholdProperties {

    private int heartRateMin = 50;
    private int heartRateMax = 120;
    private int systolicBpMin = 90;
    private int systolicBpMax = 180;
    private int diastolicBpMin = 60;
    private int diastolicBpMax = 110;
    private BigDecimal temperatureMin = new BigDecimal("35.0");
    private BigDecimal temperatureMax = new BigDecimal("38.5");
    private int oxygenSaturationMin = 92;
}
