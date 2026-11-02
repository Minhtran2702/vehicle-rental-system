package com.vehiclerental.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

/** Bảng bookings. Trạng thái: PENDING, CONFIRMED, REJECTED, IN_PROGRESS, COMPLETED, CANCELLED. */
@Entity
@Table(name = "bookings")
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "customer_id", nullable = false)
    private UUID customerId;

    @Column(name = "vehicle_id", nullable = false)
    private UUID vehicleId;

    @Column(name = "coupon_id")
    private Long couponId;

    @Column(name = "pickup_datetime", nullable = false)
    private LocalDateTime pickupDatetime;

    @Column(name = "return_datetime", nullable = false)
    private LocalDateTime returnDatetime;

    @Column(name = "pickup_location", nullable = false)
    private String pickupLocation;

    @Column(name = "return_location", nullable = false)
    private String returnLocation;

    @Column(name = "total_days", nullable = false)
    private Integer totalDays;

    @Column(name = "subtotal", nullable = false, precision = 12, scale = 2)
    private BigDecimal subtotal;

    @Column(name = "discount", nullable = false, precision = 12, scale = 2)
    private BigDecimal discount;

    @Column(name = "tax", nullable = false, precision = 12, scale = 2)
    private BigDecimal tax;

    @Column(name = "total_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "status", nullable = false, length = 20)
    private String status;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        if (createdAt == null) createdAt = now;
        if (updatedAt == null) updatedAt = now;
    }

    @PreUpdate
    void onUpdate() { updatedAt = LocalDateTime.now(); }

    public UUID getId() { return id; }
    public UUID getCustomerId() { return customerId; }
    public void setCustomerId(UUID v) { this.customerId = v; }
    public UUID getVehicleId() { return vehicleId; }
    public void setVehicleId(UUID v) { this.vehicleId = v; }
    public Long getCouponId() { return couponId; }
    public void setCouponId(Long v) { this.couponId = v; }
    public LocalDateTime getPickupDatetime() { return pickupDatetime; }
    public void setPickupDatetime(LocalDateTime v) { this.pickupDatetime = v; }
    public LocalDateTime getReturnDatetime() { return returnDatetime; }
    public void setReturnDatetime(LocalDateTime v) { this.returnDatetime = v; }
    public String getPickupLocation() { return pickupLocation; }
    public void setPickupLocation(String v) { this.pickupLocation = v; }
    public String getReturnLocation() { return returnLocation; }
    public void setReturnLocation(String v) { this.returnLocation = v; }
    public Integer getTotalDays() { return totalDays; }
    public void setTotalDays(Integer v) { this.totalDays = v; }
    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal v) { this.subtotal = v; }
    public BigDecimal getDiscount() { return discount; }
    public void setDiscount(BigDecimal v) { this.discount = v; }
    public BigDecimal getTax() { return tax; }
    public void setTax(BigDecimal v) { this.tax = v; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal v) { this.totalAmount = v; }
    public String getStatus() { return status; }
    public void setStatus(String v) { this.status = v; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
