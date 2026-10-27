package com.vehiclerental.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AddressRequest(
        @NotBlank(message = "Vui lòng nhập tên gợi nhớ") @Size(max = 50) String label,
        @NotBlank(message = "Vui lòng nhập số nhà, đường") @Size(max = 255) String addressLine,
        @Size(max = 100) String ward,
        @Size(max = 100) String district,
        @NotBlank(message = "Vui lòng nhập tỉnh / thành phố") @Size(max = 100) String city,
        @Size(max = 100) String country,
        @Size(max = 20) String postalCode,
        Boolean defaultAddress) {
}
