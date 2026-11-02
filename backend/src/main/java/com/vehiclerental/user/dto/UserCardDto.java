package com.vehiclerental.user.dto;

import java.util.UUID;

/** Thông tin một người dùng khi người khác xem (ví dụ chủ xe xem khách thuê). Dữ liệu nhạy cảm bị che trừ khi là chính chủ hoặc admin. */
public record UserCardDto(UUID id, String fullName, String avatarUrl, String bio, String phone, String email,
                          String idCardNumber, String driverLicenseNumber, boolean masked) {
}
