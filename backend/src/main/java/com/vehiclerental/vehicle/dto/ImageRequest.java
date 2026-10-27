package com.vehiclerental.vehicle.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Thêm ảnh bằng đường dẫn ảnh (đường dẫn lấy từ API upload ảnh). */
public record ImageRequest(@NotBlank(message = "Thiếu đường dẫn ảnh") @Size(max = 500) String imageUrl) {
}
