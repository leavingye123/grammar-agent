package com.grammaragent.ai.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = "app.ai-tutor")
public class AiTutorProperties {
    private boolean enabled;
    private String baseUrl = "";
    private String apiKey = "";
    private String model = "";
    private int timeoutSeconds = 30;
    private double temperature = 0.3;
    private int maxTokens = 600;

    public boolean isConfigured() {
        if (!enabled || baseUrl == null || baseUrl.isBlank() || apiKey == null || apiKey.isBlank()
                || model == null || model.isBlank() || timeoutSeconds < 1 || timeoutSeconds > 60
                || !Double.isFinite(temperature) || temperature < 0 || temperature > 2
                || maxTokens < 1 || maxTokens > 2000) return false;
        try {
            var uri = java.net.URI.create(baseUrl);
            return ("https".equals(uri.getScheme()) || "http".equals(uri.getScheme()))
                    && uri.getHost() != null && uri.getUserInfo() == null
                    && uri.getQuery() == null && uri.getFragment() == null;
        } catch (IllegalArgumentException exception) {
            return false;
        }
    }
}
