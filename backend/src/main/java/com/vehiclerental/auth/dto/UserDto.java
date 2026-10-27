package com.vehiclerental.auth.dto;

import java.util.UUID;

/** Thông tin người dùng trả về cho web / app. role là "CUSTOMER" hoặc "ADMIN". */
public record UserDto(UUID id, String email, String fullName, String role, String avatarUrl) {
}
