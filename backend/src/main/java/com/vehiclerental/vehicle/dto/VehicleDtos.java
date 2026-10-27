package com.vehiclerental.vehicle.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/** Các kiểu dữ liệu trả về cho xe của chủ xe. */
public final class VehicleDtos {
    private VehicleDtos() {}

    public record ImageDto(Long id, String imageUrl, boolean primaryImage, int displayOrder) {}

    public record LocationDto(BigDecimal latitude, BigDecimal longitude, LocalDateTime lastUpdated) {}

    public record MaintenanceDto(Long id, String maintenanceType, String description, BigDecimal cost,
                                 LocalDate performedDate, LocalDate nextDueDate, LocalDateTime createdAt) {}

    /** Dùng cho danh sách "Xe của tôi". */
    public record VehicleSummary(UUID id, String name, String licensePlate, int seats, String transmission, String fuelType,
                                 BigDecimal pricePerDay, String status, String coverImageUrl, BigDecimal averageRating, int totalReviews) {}

    /** Chi tiết đầy đủ của 1 xe. */
    public record VehicleDetail(UUID id, UUID ownerId, Long brandId, String brand, Long categoryId, String category,
                                String model, String name, String licensePlate, String color, String transmission, String fuelType,
                                int seats, int year, int mileage, BigDecimal pricePerDay, BigDecimal securityDeposit,
                                String description, String status, BigDecimal averageRating, int totalReviews,
                                List<ImageDto> images, List<String> features, LocationDto location, LocalDateTime createdAt) {}
}
