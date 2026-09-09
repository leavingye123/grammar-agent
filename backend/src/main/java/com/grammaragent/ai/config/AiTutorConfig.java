package com.grammaragent.ai.config;

import com.grammaragent.ai.llm.DisabledLLMProvider;
import com.grammaragent.ai.llm.LLMProvider;
import com.grammaragent.ai.llm.OpenAiCompatibleProvider;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

import java.net.http.HttpClient;
import java.time.Duration;

@Configuration
@EnableConfigurationProperties(AiTutorProperties.class)
public class AiTutorConfig {
    @Bean
    @ConditionalOnMissingBean(LLMProvider.class)
    public LLMProvider llmProvider(AiTutorProperties properties) {
        if (!properties.isConfigured()) return new DisabledLLMProvider();
        var timeout = Duration.ofSeconds(properties.getTimeoutSeconds());
        var factory = new JdkClientHttpRequestFactory(HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(Math.min(properties.getTimeoutSeconds(), 10)))
                .followRedirects(HttpClient.Redirect.NEVER).build());
        factory.setReadTimeout(timeout);
        // Dedicated client: credentials never reach unrelated backend HTTP clients.
        var client = RestClient.builder().requestFactory(factory).build();
        return new OpenAiCompatibleProvider(client, properties);
    }
}
