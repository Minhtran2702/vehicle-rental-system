package com.vehiclerental.vehicle;

import com.vehiclerental.audit.AuditService;
import com.vehiclerental.common.AppException;
import com.vehiclerental.common.AuthPrincipal;
import com.vehiclerental.common.SecurityUtils;
import com.vehiclerental.entity.Brand;
import com.vehiclerental.entity.Category;
import com.vehiclerental.entity.MaintenanceRecord;
import com.vehiclerental.entity.Vehicle;
import com.vehiclerental.entity.VehicleFeature;
import com.vehiclerental.entity.VehicleImage;
import com.vehiclerental.entity.VehicleLocation;
import com.vehiclerental.repository.BrandRepository;
import com.vehiclerental.repository.CategoryRepository;
import com.vehiclerental.repository.MaintenanceRecordRepository;
import com.vehiclerental.repository.VehicleFeatureRepository;
import com.vehiclerental.repository.VehicleImageRepository;
import com.vehiclerental.repository.VehicleLocationRepository;
import com.vehiclerental.repository.VehicleRepository;
import com.vehiclerental.vehicle.dto.CreateVehicleRequest;
import com.vehiclerental.vehicle.dto.LocationRequest;
import com.vehiclerental.vehicle.dto.MaintenanceRequest;
import com.vehiclerental.vehicle.dto.VehicleDtos.ImageDto;
import com.vehiclerental.vehicle.dto.VehicleDtos.LocationDto;
import com.vehiclerental.vehicle.dto.VehicleDtos.MaintenanceDto;
import com.vehiclerental.vehicle.dto.VehicleDtos.VehicleDetail;
import com.vehiclerental.vehicle.dto.VehicleDtos.VehicleSummary;
import com.vehiclerental.vehicle.dto.VehicleRequest;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Chủ xe quản lý xe của mình: thông tin, trạng thái, ảnh, tiện ích, vị trí, bảo dưỡng.
 * Quyền: chủ xe làm mọi thao tác trên xe CỦA MÌNH; ADMIN được xem, đổi trạng thái và ghi bảo dưỡng trên mọi xe.
 */
@Service
public class OwnerVehicleService {

    private static final int MAX_IMAGES = 10;

    private final VehicleRepository vehicles;
    private final BrandRepository brands;
    private final CategoryRepository categories;
    private final VehicleImageRepository images;
    private final VehicleFeatureRepository features;
    private final VehicleLocationRepository locations;
    private final MaintenanceRecordRepository maintenance;
    private final AuditService audit;

    public OwnerVehicleService(VehicleRepository vehicles, BrandRepository brands, CategoryRepository categories,
                               VehicleImageRepository images, VehicleFeatureRepository features,
                               VehicleLocationRepository locations, MaintenanceRecordRepository maintenance, AuditService audit) {
        this.vehicles = vehicles;
        this.brands = brands;
        this.categories = categories;
        this.images = images;
        this.features = features;
        this.locations = locations;
        this.maintenance = maintenance;
        this.audit = audit;
    }

    // ---------------- Danh sách / chi tiết ----------------
    @Transactional(readOnly = true)
    public List<VehicleSummary> listMine() {
        UUID me = SecurityUtils.current().id();
        return vehicles.findByOwnerIdOrderByCreatedAtDesc(me).stream().map(this::toSummary).toList();
    }

    @Transactional(readOnly = true)
    public VehicleDetail get(UUID id) {
        return toDetail(load(id, true));
    }

    // ---------------- Đăng xe / sửa xe ----------------
    @Transactional
    public VehicleDetail create(CreateVehicleRequest req) {
        UUID me = SecurityUtils.current().id();
        VehicleRequest r = req.vehicle();
        String plate = r.licensePlate().trim().toUpperCase();
        if (vehicles.existsByLicensePlateIgnoreCase(plate)) throw AppException.conflict("Biển số đã tồn tại");
        List<String> imageUrls = req.imageUrls() == null ? List.of() : req.imageUrls().stream().filter(s -> s != null && !s.isBlank()).toList();
        if (imageUrls.size() > MAX_IMAGES) throw AppException.badRequest("Tối đa " + MAX_IMAGES + " ảnh");

        Vehicle v = new Vehicle();
        v.setOwnerId(me);
        applyInfo(v, r);
        v.setLicensePlate(plate);
        v.setStatus(imageUrls.isEmpty() ? "INACTIVE" : "ACTIVE");
        v.setAverageRating(BigDecimal.ZERO);
        v.setTotalReviews(0);
        v = vehicles.save(v);

        short order = 0;
        for (String url : imageUrls) addImageRow(v.getId(), url.trim(), order == 0, order++);
        if (req.features() != null) replaceFeatures(v.getId(), req.features());
        if (req.location() != null) upsertLocation(v.getId(), req.location());

        audit.log("VEHICLE_CREATE", "vehicle", v.getId(), null, snapshot(v));
        return toDetail(v);
    }

    @Transactional
    public VehicleDetail update(UUID id, VehicleRequest r) {
        Vehicle v = load(id, false);
        String plate = r.licensePlate().trim().toUpperCase();
        if (vehicles.existsByLicensePlateIgnoreCaseAndIdNot(plate, id)) throw AppException.conflict("Biển số đã tồn tại");
        Map<String, Object> before = snapshot(v);
        applyInfo(v, r);
        v.setLicensePlate(plate);
        v = vehicles.save(v);
        audit.log("VEHICLE_UPDATE", "vehicle", v.getId(), before, snapshot(v));
        return toDetail(v);
    }

    /** Chủ xe: ẩn / hiện / bảo dưỡng. Admin cũng được đổi. Không cho ACTIVE nếu chưa có ảnh. */
    @Transactional
    public VehicleDetail setStatus(UUID id, String status) {
        Vehicle v = load(id, true);
        if ("ACTIVE".equals(status) && images.countByVehicleId(id) == 0) {
            throw AppException.badRequest("Cần ít nhất 1 ảnh trước khi cho thuê");
        }
        String old = v.getStatus();
        v.setStatus(status);
        v = vehicles.save(v);
        if (!old.equals(status)) {
            audit.log("VEHICLE_STATUS_CHANGE", "vehicle", id, Map.of("status", old), Map.of("status", status));
        }
        return toDetail(v);
    }

    // ---------------- Ảnh ----------------
    @Transactional
    public VehicleDetail addImage(UUID id, String url) {
        Vehicle v = load(id, false);
        long count = images.countByVehicleId(id);
        if (count >= MAX_IMAGES) throw AppException.badRequest("Tối đa " + MAX_IMAGES + " ảnh");
        addImageRow(id, url.trim(), count == 0, (short) count);
        return toDetail(v);
    }

    @Transactional
    public VehicleDetail removeImage(UUID id, Long imageId) {
        Vehicle v = load(id, false);
        VehicleImage img = images.findByIdAndVehicleId(imageId, id).orElseThrow(() -> AppException.notFound("Không tìm thấy ảnh"));
        boolean wasPrimary = img.isPrimaryImage();
        images.delete(img);
        images.flush();
        List<VehicleImage> rest = images.findByVehicleIdOrderByDisplayOrderAscIdAsc(id);
        if (wasPrimary && !rest.isEmpty()) {
            rest.get(0).setPrimaryImage(true);
            images.save(rest.get(0));
        }
        if (rest.isEmpty() && "ACTIVE".equals(v.getStatus())) {
            v.setStatus("INACTIVE"); // không còn ảnh thì tự ẩn tin
            vehicles.save(v);
        }
        return toDetail(v);
    }

    @Transactional
    public VehicleDetail setPrimaryImage(UUID id, Long imageId) {
        Vehicle v = load(id, false);
        images.findByIdAndVehicleId(imageId, id).orElseThrow(() -> AppException.notFound("Không tìm thấy ảnh"));
        for (VehicleImage i : images.findByVehicleIdOrderByDisplayOrderAscIdAsc(id)) {
            boolean primary = i.getId().equals(imageId);
            if (i.isPrimaryImage() != primary) {
                i.setPrimaryImage(primary);
                images.save(i);
            }
        }
        return toDetail(v);
    }

    // ---------------- Tiện ích / vị trí ----------------
    @Transactional
    public VehicleDetail saveFeatures(UUID id, List<String> names) {
        Vehicle v = load(id, false);
        replaceFeatures(id, names);
        return toDetail(v);
    }

    @Transactional
    public VehicleDetail saveLocation(UUID id, LocationRequest req) {
        Vehicle v = load(id, false);
        upsertLocation(id, req);
        return toDetail(v);
    }

    // ---------------- Bảo dưỡng ----------------
    @Transactional(readOnly = true)
    public List<MaintenanceDto> listMaintenance(UUID id) {
        load(id, true);
        return maintenance.findByVehicleIdOrderByPerformedAtDesc(id).stream().map(this::toDto).toList();
    }

    @Transactional
    public List<MaintenanceDto> addMaintenance(UUID id, MaintenanceRequest req) {
        load(id, true);
        MaintenanceRecord m = new MaintenanceRecord();
        m.setVehicleId(id);
        m.setMaintenanceType(req.maintenanceType().trim());
        m.setDescription(req.description() == null || req.description().isBlank() ? null : req.description().trim());
        m.setCost(req.cost());
        m.setPerformedAt(req.performedDate().atStartOfDay());
        m.setNextDueAt(req.nextDueDate() == null ? null : req.nextDueDate().atStartOfDay());
        maintenance.save(m);
        return listMaintenance(id);
    }

    @Transactional
    public List<MaintenanceDto> deleteMaintenance(UUID id, Long recordId) {
        load(id, true);
        MaintenanceRecord m = maintenance.findByIdAndVehicleId(recordId, id).orElseThrow(() -> AppException.notFound("Không tìm thấy bản ghi bảo dưỡng"));
        maintenance.delete(m);
        maintenance.flush();
        return listMaintenance(id);
    }

    // ---------------- Hàm phụ ----------------
    /** Lấy xe và kiểm tra quyền: chủ xe luôn được; admin chỉ được khi allowAdmin = true. */
    private Vehicle load(UUID id, boolean allowAdmin) {
        Vehicle v = vehicles.findById(id).orElseThrow(() -> AppException.notFound("Không tìm thấy xe"));
        AuthPrincipal me = SecurityUtils.current();
        boolean owner = v.getOwnerId().equals(me.id());
        if (!owner && !(allowAdmin && me.isAdmin())) throw AppException.forbidden("Bạn không có quyền với xe này");
        return v;
    }

    private void applyInfo(Vehicle v, VehicleRequest r) {
        Brand b = brands.findById(r.brandId()).orElseThrow(() -> AppException.badRequest("Hãng xe không tồn tại"));
        Category c = categories.findById(r.categoryId()).orElseThrow(() -> AppException.badRequest("Loại xe không tồn tại"));
        v.setBrand(b);
        v.setCategory(c);
        v.setModel(r.model().trim());
        v.setColor(r.color() == null || r.color().isBlank() ? null : r.color().trim());
        v.setTransmission(r.transmission());
        v.setFuelType(r.fuelType());
        v.setSeats(r.seats().shortValue());
        v.setYear(r.year().shortValue());
        v.setMileage(r.mileage());
        v.setPricePerDay(r.pricePerDay());
        v.setSecurityDeposit(r.securityDeposit());
        v.setDescription(r.description() == null || r.description().isBlank() ? null : r.description().trim());
    }

    private void addImageRow(UUID vehicleId, String url, boolean primary, short order) {
        VehicleImage i = new VehicleImage();
        i.setVehicleId(vehicleId);
        i.setImageUrl(url);
        i.setPrimaryImage(primary);
        i.setDisplayOrder(order);
        images.save(i);
    }

    private void replaceFeatures(UUID vehicleId, List<String> names) {
        Set<String> clean = new LinkedHashSet<>();
        for (String n : names) {
            if (n != null && !n.isBlank()) clean.add(n.trim());
        }
        features.deleteByVehicleId(vehicleId);
        features.flush();
        for (String n : clean) {
            VehicleFeature f = new VehicleFeature();
            f.setVehicleId(vehicleId);
            f.setFeatureName(n.length() > 100 ? n.substring(0, 100) : n);
            features.save(f);
        }
    }

    private void upsertLocation(UUID vehicleId, LocationRequest req) {
        VehicleLocation l = locations.findByVehicleId(vehicleId).orElseGet(() -> {
            VehicleLocation x = new VehicleLocation();
            x.setVehicleId(vehicleId);
            x.setSpeed(BigDecimal.ZERO);
            x.setHeading(BigDecimal.ZERO);
            x.setAccuracy(BigDecimal.ZERO);
            return x;
        });
        l.setLatitude(req.latitude());
        l.setLongitude(req.longitude());
        l.setLastUpdated(LocalDateTime.now());
        locations.save(l);
    }

    private Map<String, Object> snapshot(Vehicle v) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("licensePlate", v.getLicensePlate());
        m.put("brand", v.getBrand().getName());
        m.put("model", v.getModel());
        m.put("pricePerDay", v.getPricePerDay());
        m.put("securityDeposit", v.getSecurityDeposit());
        m.put("status", v.getStatus());
        return m;
    }

    private VehicleSummary toSummary(Vehicle v) {
        List<VehicleImage> imgs = images.findByVehicleIdOrderByDisplayOrderAscIdAsc(v.getId());
        String cover = imgs.stream().filter(VehicleImage::isPrimaryImage).map(VehicleImage::getImageUrl).findFirst()
                .orElse(imgs.isEmpty() ? null : imgs.get(0).getImageUrl());
        return new VehicleSummary(v.getId(), v.getBrand().getName() + " " + v.getModel(), v.getLicensePlate(), v.getSeats(),
                v.getTransmission(), v.getFuelType(), v.getPricePerDay(), v.getStatus(), cover, v.getAverageRating(), v.getTotalReviews());
    }

    private VehicleDetail toDetail(Vehicle v) {
        List<ImageDto> imgs = images.findByVehicleIdOrderByDisplayOrderAscIdAsc(v.getId()).stream()
                .map(i -> new ImageDto(i.getId(), i.getImageUrl(), i.isPrimaryImage(), i.getDisplayOrder())).toList();
        List<String> feats = features.findByVehicleIdOrderByIdAsc(v.getId()).stream().map(VehicleFeature::getFeatureName).toList();
        LocationDto loc = locations.findByVehicleId(v.getId())
                .map(l -> new LocationDto(l.getLatitude(), l.getLongitude(), l.getLastUpdated())).orElse(null);
        return new VehicleDetail(v.getId(), v.getOwnerId(), v.getBrand().getId(), v.getBrand().getName(), v.getCategory().getId(),
                v.getCategory().getName(), v.getModel(), v.getBrand().getName() + " " + v.getModel(), v.getLicensePlate(), v.getColor(),
                v.getTransmission(), v.getFuelType(), v.getSeats(), v.getYear(), v.getMileage(), v.getPricePerDay(),
                v.getSecurityDeposit(), v.getDescription(), v.getStatus(), v.getAverageRating(), v.getTotalReviews(),
                imgs, feats, loc, v.getCreatedAt());
    }

    private MaintenanceDto toDto(MaintenanceRecord m) {
        return new MaintenanceDto(m.getId(), m.getMaintenanceType(), m.getDescription(), m.getCost(), m.getPerformedAt().toLocalDate(),
                m.getNextDueAt() == null ? null : m.getNextDueAt().toLocalDate(), m.getCreatedAt());
    }
}
