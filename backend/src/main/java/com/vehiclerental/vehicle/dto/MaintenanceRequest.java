package com.vehiclerental.vehicle.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.LocalDate;

public record MaintenanceRequest(
        @NotBlank(message = "Vui lòng nhập hạng mục") @Size(max = 100) String maintenanceType,
        @Size(max = 1000) String description,
        @NotNull(message = "Vui lòng nhập chi phí") @DecimalMin(value = "0", message = "Chi phí không hợp lệ") BigDecimal cost,
        @NotNull(message = "Vui lòng chọn ngày thực hiện") LocalDate performedDate,
        LocalDate nextDueDate) {
}
