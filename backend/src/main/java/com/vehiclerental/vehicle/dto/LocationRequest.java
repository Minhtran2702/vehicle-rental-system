package com.vehiclerental.vehicle.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public record LocationRequest(
        @NotNull(message = "Thiếu vĩ độ") @DecimalMin("-90") @DecimalMax("90") BigDecimal latitude,
        @NotNull(message = "Thiếu kinh độ") @DecimalMin("-180") @DecimalMax("180") BigDecimal longitude) {
}
