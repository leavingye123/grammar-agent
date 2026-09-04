package com.grammaragent.common.response;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Backend health status")
public record HealthResponse(
        @Schema(example = "UP") String status,
        @Schema(example = "grammar-agent-backend") String service
) {
}
