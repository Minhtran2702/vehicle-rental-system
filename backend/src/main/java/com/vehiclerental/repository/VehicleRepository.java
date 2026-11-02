package com.vehiclerental.repository;

import com.vehiclerental.entity.Vehicle;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VehicleRepository extends JpaRepository<Vehicle, UUID> {
    /** Khoá dòng xe khi tạo đơn để hai người không đặt trùng cùng lúc. */
    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select v from Vehicle v where v.id = :id")
    java.util.Optional<Vehicle> lockById(@org.springframework.data.repository.query.Param("id") UUID id);

    List<Vehicle> findByOwnerIdOrderByCreatedAtDesc(UUID ownerId);

    boolean existsByLicensePlateIgnoreCase(String licensePlate);

    boolean existsByLicensePlateIgnoreCaseAndIdNot(String licensePlate, UUID id);
}
