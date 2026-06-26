package com.mednova.gateway.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiGatewayConfig {

    @Bean
    OpenAPI gatewayOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("MedNova AI — API Gateway")
                        .description("""
                                Point d'entrée unique de la plateforme MedNova AI.
                                Sélectionnez un microservice dans la liste déroulante pour consulter sa documentation.
                                """)
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("MedNova AI")
                                .url("https://github.com/ngmiguel/mednova-ai")));
    }
}
