package com.vehiclerental.repository;

import com.vehiclerental.entity.VehicleLocation;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VehicleLocationRepository extends JpaRepository<VehicleLocation, Long> {
    Optional<VehicleLocation> findByVehicleId(UUID vehicleId);
}
