package com.mednova.gateway.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@ConfigurationProperties(prefix = "mednova.gateway")
public class GatewayProperties {

    private List<String> publicPaths = new ArrayList<>();
}
