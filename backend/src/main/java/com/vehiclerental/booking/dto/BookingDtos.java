package com.vehiclerental.booking.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public final class BookingDtos {
    private BookingDtos() {}

    /** Xem giá tạm tính (chưa tạo đơn). */
    public record QuoteRequest(
            @NotNull(message = "Vui lòng chọn xe") UUID vehicleId,
            @NotNull(message = "Vui lòng chọn giờ nhận xe") LocalDateTime pickupDatetime,
            @NotNull(message = "Vui lòng chọn giờ trả xe") LocalDateTime returnDatetime,
            @Size(max = 30) String couponCode) {
    }

    /** Tạo đơn đặt xe. */
    public record CreateBookingRequest(
            @NotNull(message = "Vui lòng chọn xe") UUID vehicleId,
            @NotNull(message = "Vui lòng chọn giờ nhận xe") LocalDateTime pickupDatetime,
            @NotNull(message = "Vui lòng chọn giờ trả xe") LocalDateTime returnDatetime,
            @Size(max = 255) String pickupLocation,
            @Size(max = 255) String returnLocation,
            @Size(max = 30) String couponCode) {
    }

    /** Kết quả tính giá. securityDeposit là tiền cọc, KHÔNG nằm trong totalAmount. */
    public record Quote(
            UUID vehicleId,
            String vehicleName,
            String imageUrl,
            BigDecimal pricePerDay,
            int totalDays,
            BigDecimal subtotal,
            String couponCode,
            BigDecimal discount,
            BigDecimal tax,
            BigDecimal totalAmount,
            BigDecimal securityDeposit) {
    }

    public record BusyPeriod(LocalDateTime from, LocalDateTime to) {
    }

    /** available = false thì reason nói rõ vì sao. */
    public record Availability(boolean available, String reason, List<BusyPeriod> busy) {
    }

    public record StatusHistoryDto(String status, String note, LocalDateTime at) {
    }

    public record BookingDto(
            UUID id,
            UUID vehicleId,
            String vehicleName,
            String imageUrl,
            UUID customerId,
            String customerName,
            LocalDateTime pickupDatetime,
            LocalDateTime returnDatetime,
            String pickupLocation,
            String returnLocation,
            int totalDays,
            BigDecimal subtotal,
            BigDecimal discount,
            BigDecimal tax,
            BigDecimal totalAmount,
            BigDecimal securityDeposit,
            String couponCode,
            String status,
            LocalDateTime createdAt,
            List<StatusHistoryDto> history) {
    }
}
