package com.vehiclerental.vehicle.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

/** Thông tin cơ bản của xe (dùng khi đăng xe mới và khi sửa xe). */
public record VehicleRequest(
        @NotNull(message = "Vui lòng chọn hãng xe") Long brandId,
        @NotNull(message = "Vui lòng chọn loại xe") Long categoryId,
        @NotBlank(message = "Vui lòng nhập tên dòng xe") @Size(max = 100) String model,
        @NotBlank(message = "Vui lòng nhập biển số")
        @Pattern(regexp = "^\\d{2}[A-Za-z]{1,2}\\d?-\\d{3}\\.\\d{2}$", message = "Biển số dạng 51K-123.45") String licensePlate,
        @Size(max = 30) String color,
        @NotBlank @Pattern(regexp = "AUTO|MANUAL", message = "Hộp số phải là AUTO hoặc MANUAL") String transmission,
        @NotBlank @Pattern(regexp = "GASOLINE|DIESEL|ELECTRIC|HYBRID", message = "Nhiên liệu phải là GASOLINE, DIESEL, ELECTRIC hoặc HYBRID") String fuelType,
        @NotNull @Min(value = 1, message = "Số chỗ từ 1 đến 16") @Max(value = 16, message = "Số chỗ từ 1 đến 16") Integer seats,
        @NotNull @Min(value = 1990, message = "Năm sản xuất không hợp lệ") @Max(value = 2100, message = "Năm sản xuất không hợp lệ") Integer year,
        @NotNull @Min(value = 0, message = "Số km không hợp lệ") Integer mileage,
        @NotNull @DecimalMin(value = "50000", message = "Giá thuê tối thiểu 50.000đ") BigDecimal pricePerDay,
        @NotNull @DecimalMin(value = "0", message = "Tiền cọc không hợp lệ") BigDecimal securityDeposit,
        @Size(max = 2000) String description) {
}
