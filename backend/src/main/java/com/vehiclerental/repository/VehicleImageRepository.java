package com.vehiclerental.repository;

import com.vehiclerental.entity.VehicleImage;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VehicleImageRepository extends JpaRepository<VehicleImage, Long> {
    List<VehicleImage> findByVehicleIdOrderByDisplayOrderAscIdAsc(UUID vehicleId);

    Optional<VehicleImage> findByIdAndVehicleId(Long id, UUID vehicleId);

    long countByVehicleId(UUID vehicleId);
}
