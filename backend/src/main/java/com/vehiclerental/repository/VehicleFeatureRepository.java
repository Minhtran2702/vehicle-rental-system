package com.vehiclerental.repository;

import com.vehiclerental.entity.VehicleFeature;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VehicleFeatureRepository extends JpaRepository<VehicleFeature, Long> {
    List<VehicleFeature> findByVehicleIdOrderByIdAsc(UUID vehicleId);

    void deleteByVehicleId(UUID vehicleId);
}
