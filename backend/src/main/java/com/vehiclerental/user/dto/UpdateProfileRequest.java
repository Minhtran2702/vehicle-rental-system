package com.vehiclerental.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

/** Không có email, vai trò, trạng thái: các thuộc tính này người dùng không được tự đổi. */
public record UpdateProfileRequest(
        @NotBlank(message = "Vui lòng nhập họ tên") @Size(max = 150) String fullName,
        @Pattern(regexp = "^0\\d{9}$", message = "Số điện thoại gồm 10 số, bắt đầu bằng 0") String phone,
        @Past(message = "Ngày sinh phải ở quá khứ") LocalDate dateOfBirth,
        @Pattern(regexp = "MALE|FEMALE|OTHER", message = "Giới tính phải là MALE, FEMALE hoặc OTHER") String gender,
        @Size(max = 1000) String bio,
        @Size(max = 500) String avatarUrl,
        @Size(max = 30) String idCardNumber,
        @Size(max = 30) String driverLicenseNumber) {
}
