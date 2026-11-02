package com.vehiclerental.repository;

import com.vehiclerental.entity.Booking;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BookingRepository extends JpaRepository<Booking, UUID> {

    List<Booking> findByCustomerIdOrderByCreatedAtDesc(UUID customerId);

    /** Đơn của các xe do một chủ xe sở hữu (dùng cho việc chấp nhận / từ chối ở CV61). */
    @Query("select b from Booking b where b.vehicleId in (select v.id from Vehicle v where v.ownerId = :ownerId) order by b.createdAt desc")
    List<Booking> findByOwner(@Param("ownerId") UUID ownerId);

    /** Có đơn nào đang giữ xe trong khoảng [from, to) không (hai khoảng giao nhau). */
    @Query("select count(b) > 0 from Booking b where b.vehicleId = :vehicleId and b.status in :statuses "
            + "and b.pickupDatetime < :to and b.returnDatetime > :from")
    boolean existsOverlap(@Param("vehicleId") UUID vehicleId, @Param("statuses") Collection<String> statuses,
                          @Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    /** Các đơn giữ xe từ thời điểm `from` trở đi, để hiển thị lịch bận. */
    @Query("select b from Booking b where b.vehicleId = :vehicleId and b.status in :statuses and b.returnDatetime > :from order by b.pickupDatetime")
    List<Booking> findBusy(@Param("vehicleId") UUID vehicleId, @Param("statuses") Collection<String> statuses,
                           @Param("from") LocalDateTime from);
}
