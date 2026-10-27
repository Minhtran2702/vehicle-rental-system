package com.vehiclerental.repository;

import com.vehiclerental.entity.MaintenanceRecord;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MaintenanceRecordRepository extends JpaRepository<MaintenanceRecord, Long> {
    List<MaintenanceRecord> findByVehicleIdOrderByPerformedAtDesc(UUID vehicleId);

    Optional<MaintenanceRecord> findByIdAndVehicleId(Long id, UUID vehicleId);
}
