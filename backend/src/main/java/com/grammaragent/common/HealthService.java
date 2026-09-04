package com.grammaragent.common;

import com.grammaragent.common.response.HealthResponse;
import org.springframework.stereotype.Service;

@Service
public class HealthService {

    private static final String SERVICE_NAME = "grammar-agent-backend";

    public HealthResponse getHealth() {
        return new HealthResponse("UP", SERVICE_NAME);
    }
}
