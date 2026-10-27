package com.vehiclerental.auth.dto;

import jakarta.validation.constraints.NotBlank;

public record RefreshRequest(@NotBlank(message = "Thiếu refreshToken") String refreshToken) {
}
