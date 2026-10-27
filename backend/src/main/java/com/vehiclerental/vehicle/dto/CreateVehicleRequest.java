package com.vehiclerental.vehicle.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;

/** Đăng xe mới: thông tin xe + (tùy chọn) ảnh, tiện ích, vị trí – tạo luôn trong 1 lần gọi. */
public record CreateVehicleRequest(
        @Valid @NotNull(message = "Thiếu thông tin xe") VehicleRequest vehicle,
        @Size(max = 10, message = "Tối đa 10 ảnh") List<String> imageUrls,
        @Size(max = 30, message = "Tối đa 30 tiện ích") List<String> features,
        @Valid LocationRequest location) {
}
