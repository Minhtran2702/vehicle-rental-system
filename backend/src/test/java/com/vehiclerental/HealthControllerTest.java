package com.vehiclerental;

import static org.junit.jupiter.api.Assertions.assertEquals;

import com.vehiclerental.common.ApiResponse;
import com.vehiclerental.common.HealthController;
import org.junit.jupiter.api.Test;

class HealthControllerTest {
    @Test
    void healthReturnsUp() {
        ApiResponse<java.util.Map<String, String>> r = new HealthController().health();
        assertEquals("UP", r.data().get("status"));
    }
}
