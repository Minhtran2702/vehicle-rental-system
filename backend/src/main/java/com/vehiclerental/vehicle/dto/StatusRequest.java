package com.vehiclerental.vehicle.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record StatusRequest(
        @NotBlank @Pattern(regexp = "ACTIVE|INACTIVE|MAINTENANCE", message = "Trạng thái phải là ACTIVE, INACTIVE hoặc MAINTENANCE") String status) {
}
