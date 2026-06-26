package com.mednova.common.config;

import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.context.annotation.ComponentScan;

@AutoConfiguration
@ComponentScan(basePackages = "com.mednova.common.handler")
public class CommonLibAutoConfiguration {
}
