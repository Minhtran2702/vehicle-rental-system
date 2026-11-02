package com.vehiclerental.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

/** Bảng booking_status_history: mỗi lần đơn đổi trạng thái thêm một dòng. */
@Entity
@Table(name = "booking_status_history")
public class BookingStatusHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "booking_id", nullable = false)
    private UUID bookingId;

    @Column(name = "status", nullable = false, length = 20)
    private String status;

    @Column(name = "changed_by")
    private UUID changedBy;

    @Column(name = "note", length = 500)
    private String note;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public BookingStatusHistory() {}

    public BookingStatusHistory(UUID bookingId, String status, UUID changedBy, String note) {
        this.bookingId = bookingId;
        this.status = status;
        this.changedBy = changedBy;
        this.note = note;
    }

    public Long getId() { return id; }
    public UUID getBookingId() { return bookingId; }
    public String getStatus() { return status; }
    public UUID getChangedBy() { return changedBy; }
    public String getNote() { return note; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
