package com.vehiclerental.vehicle;

import com.vehiclerental.common.ApiResponse;
import com.vehiclerental.vehicle.dto.CreateVehicleRequest;
import com.vehiclerental.vehicle.dto.FeaturesRequest;
import com.vehiclerental.vehicle.dto.ImageRequest;
import com.vehiclerental.vehicle.dto.LocationRequest;
import com.vehiclerental.vehicle.dto.MaintenanceRequest;
import com.vehiclerental.vehicle.dto.StatusRequest;
import com.vehiclerental.vehicle.dto.VehicleDtos.MaintenanceDto;
import com.vehiclerental.vehicle.dto.VehicleDtos.VehicleDetail;
import com.vehiclerental.vehicle.dto.VehicleDtos.VehicleSummary;
import com.vehiclerental.vehicle.dto.VehicleRequest;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Quản lý xe của chủ xe. Tất cả cần đăng nhập (Bearer token). */
@RestController
@RequestMapping("/api/owner/vehicles")
public class OwnerVehicleController {

    private final OwnerVehicleService service;

    public OwnerVehicleController(OwnerVehicleService service) {
        this.service = service;
    }

    @GetMapping
    public ApiResponse<List<VehicleSummary>> list() {
        return ApiResponse.ok(service.listMine());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<VehicleDetail> create(@Valid @RequestBody CreateVehicleRequest req) {
        return ApiResponse.ok("Đăng xe thành công", service.create(req));
    }

    @GetMapping("/{id}")
    public ApiResponse<VehicleDetail> get(@PathVariable UUID id) {
        return ApiResponse.ok(service.get(id));
    }

    @PutMapping("/{id}")
    public ApiResponse<VehicleDetail> update(@PathVariable UUID id, @Valid @RequestBody VehicleRequest req) {
        return ApiResponse.ok("Đã cập nhật xe", service.update(id, req));
    }

    @PatchMapping("/{id}/status")
    public ApiResponse<VehicleDetail> status(@PathVariable UUID id, @Valid @RequestBody StatusRequest req) {
        return ApiResponse.ok("Đã đổi trạng thái", service.setStatus(id, req.status()));
    }

    @PostMapping("/{id}/images")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<VehicleDetail> addImage(@PathVariable UUID id, @Valid @RequestBody ImageRequest req) {
        return ApiResponse.ok(service.addImage(id, req.imageUrl()));
    }

    @DeleteMapping("/{id}/images/{imageId}")
    public ApiResponse<VehicleDetail> removeImage(@PathVariable UUID id, @PathVariable Long imageId) {
        return ApiResponse.ok(service.removeImage(id, imageId));
    }

    @PatchMapping("/{id}/images/{imageId}/primary")
    public ApiResponse<VehicleDetail> primary(@PathVariable UUID id, @PathVariable Long imageId) {
        return ApiResponse.ok(service.setPrimaryImage(id, imageId));
    }

    @PutMapping("/{id}/features")
    public ApiResponse<VehicleDetail> features(@PathVariable UUID id, @Valid @RequestBody FeaturesRequest req) {
        return ApiResponse.ok(service.saveFeatures(id, req.features()));
    }

    @PutMapping("/{id}/location")
    public ApiResponse<VehicleDetail> location(@PathVariable UUID id, @Valid @RequestBody LocationRequest req) {
        return ApiResponse.ok(service.saveLocation(id, req));
    }

    @GetMapping("/{id}/maintenance")
    public ApiResponse<List<MaintenanceDto>> maintenance(@PathVariable UUID id) {
        return ApiResponse.ok(service.listMaintenance(id));
    }

    @PostMapping("/{id}/maintenance")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<List<MaintenanceDto>> addMaintenance(@PathVariable UUID id, @Valid @RequestBody MaintenanceRequest req) {
        return ApiResponse.ok(service.addMaintenance(id, req));
    }

    @DeleteMapping("/{id}/maintenance/{recordId}")
    public ApiResponse<List<MaintenanceDto>> deleteMaintenance(@PathVariable UUID id, @PathVariable Long recordId) {
        return ApiResponse.ok(service.deleteMaintenance(id, recordId));
    }
}
