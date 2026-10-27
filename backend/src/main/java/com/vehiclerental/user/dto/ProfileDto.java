package com.vehiclerental.user.dto;

import java.time.LocalDate;
import java.util.UUID;

public record ProfileDto(UUID id, String email, String fullName, String phone, String role, String avatarUrl,
                         LocalDate dateOfBirth, String gender, String bio, String idCardNumber, String driverLicenseNumber) {
}
