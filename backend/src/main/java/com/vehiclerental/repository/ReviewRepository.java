package com.vehiclerental.repository;

import com.vehiclerental.entity.Review;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReviewRepository extends JpaRepository<Review, UUID> {
    List<Review> findByCustomerIdOrderByCreatedAtDesc(UUID customerId);

    List<Review> findByVehicleIdOrderByCreatedAtDesc(UUID vehicleId);

    Optional<Review> findByBookingId(UUID bookingId);
}
