package com.vehiclerental.auth.dto;

public record AuthResponse(UserDto user, String accessToken, String refreshToken) {
}
