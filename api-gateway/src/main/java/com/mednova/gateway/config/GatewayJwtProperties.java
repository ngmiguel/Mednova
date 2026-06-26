package com.mednova.gateway.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = "mednova.jwt")
public class GatewayJwtProperties {

    private String secret;
}
