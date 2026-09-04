package com.grammaragent.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    OpenAPI grammarAgentOpenApi() {
        return new OpenAPI().info(new Info()
                .title("GrammarAgent Backend API")
                .description("REST API for the GrammarAgent language grammar learning platform")
                .version("v1"));
    }
}
