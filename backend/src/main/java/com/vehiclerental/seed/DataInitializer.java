package com.vehiclerental.seed;

import com.vehiclerental.entity.Brand;
import com.vehiclerental.entity.Category;
import com.vehiclerental.entity.MaintenanceRecord;
import com.vehiclerental.entity.User;
import com.vehiclerental.entity.UserProfile;
import com.vehiclerental.entity.Vehicle;
import com.vehiclerental.entity.VehicleFeature;
import com.vehiclerental.entity.VehicleImage;
import com.vehiclerental.entity.VehicleLocation;
import com.vehiclerental.repository.BrandRepository;
import com.vehiclerental.repository.CategoryRepository;
import com.vehiclerental.repository.MaintenanceRecordRepository;
import com.vehiclerental.repository.RoleRepository;
import com.vehiclerental.repository.UserProfileRepository;
import com.vehiclerental.repository.UserRepository;
import com.vehiclerental.repository.VehicleFeatureRepository;
import com.vehiclerental.repository.VehicleImageRepository;
import com.vehiclerental.repository.VehicleLocationRepository;
import com.vehiclerental.repository.VehicleRepository;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Tạo dữ liệu mẫu khi chạy lần đầu (bảng users còn trống) để có tài khoản đăng nhập và vài xe để test.
 * Mật khẩu tất cả tài khoản mẫu: 123456
 *   admin@vrs.local (ADMIN) · owner@vrs.local, owner2@vrs.local, user@vrs.local (CUSTOMER)
 */
@Component
@Order(1)
public class DataInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    private final UserRepository users;
    private final RoleRepository roles;
    private final UserProfileRepository profiles;
    private final BrandRepository brands;
    private final CategoryRepository categories;
    private final VehicleRepository vehicles;
    private final VehicleImageRepository images;
    private final VehicleFeatureRepository features;
    private final VehicleLocationRepository locations;
    private final MaintenanceRecordRepository maintenance;
    private final PasswordEncoder encoder;

    public DataInitializer(UserRepository users, RoleRepository roles, UserProfileRepository profiles, BrandRepository brands,
                           CategoryRepository categories, VehicleRepository vehicles, VehicleImageRepository images,
                           VehicleFeatureRepository features, VehicleLocationRepository locations,
                           MaintenanceRecordRepository maintenance, PasswordEncoder encoder) {
        this.users = users;
        this.roles = roles;
        this.profiles = profiles;
        this.brands = brands;
        this.categories = categories;
        this.vehicles = vehicles;
        this.images = images;
        this.features = features;
        this.locations = locations;
        this.maintenance = maintenance;
        this.encoder = encoder;
    }

    @Override
    @Transactional
    public void run(String... args) {
        if (users.count() > 0) return;
        log.info("Bảng users trống → tạo dữ liệu mẫu");

        User admin = user("Quản trị viên", "admin@vrs.local", "0900000001", "ADMIN");
        User owner = user("Chủ Xe Một", "owner@vrs.local", "0900000002", "CUSTOMER");
        User owner2 = user("Chủ Xe Hai", "owner2@vrs.local", "0900000003", "CUSTOMER");
        user("Khách Thuê Xe", "user@vrs.local", "0900000004", "CUSTOMER");

        vehicle(owner, "Toyota", "Sedan", "Vios", "51K-123.45", "Trắng", "AUTO", "GASOLINE", 5, 2022, 25000, 600000, 3000000,
                "Xe sedan tiết kiệm xăng, phù hợp đi trong thành phố.", List.of("Bluetooth", "Camera lùi", "Cảm biến lùi"), 10.7769, 106.7009);
        vehicle(owner, "Honda", "SUV", "CR-V", "51H-456.78", "Đen", "AUTO", "GASOLINE", 7, 2021, 40000, 1100000, 5000000,
                "SUV 7 chỗ rộng rãi cho gia đình.", List.of("Bluetooth", "Cửa sổ trời", "Camera 360"), 10.8231, 106.6297);
        vehicle(owner, "Mazda", "Sedan", "Mazda3", "30G-222.33", "Đỏ", "AUTO", "GASOLINE", 5, 2023, 12000, 800000, 4000000,
                "Thiết kế đẹp, lái êm.", List.of("Apple CarPlay", "Camera lùi"), 10.7626, 106.6602);
        vehicle(owner, "Hyundai", "Hatchback", "i10", "59A-111.22", "Bạc", "MANUAL", "GASOLINE", 5, 2020, 60000, 450000, 2000000,
                "Nhỏ gọn, dễ đậu xe, tiết kiệm.", List.of("Bluetooth"), 10.8012, 106.7144);
        vehicle(owner2, "Kia", "MPV", "Carnival", "51G-789.01", "Xám", "AUTO", "DIESEL", 7, 2022, 30000, 1500000, 6000000,
                "MPV cao cấp, ghế thương gia.", List.of("Ghế massage", "Cửa lùa điện", "Camera 360"), 10.7721, 106.698);
        vehicle(owner2, "VinFast", "Electric", "VF 8", "51L-345.67", "Xanh", "AUTO", "ELECTRIC", 5, 2023, 8000, 1300000, 6000000,
                "SUV điện, vận hành êm, sạc nhanh.", List.of("Màn hình lớn", "Cảnh báo điểm mù", "Camera 360"), 10.7314, 106.7217);
        vehicle(owner2, "Ford", "Pickup", "Ranger", "61C-555.66", "Cam", "MANUAL", "DIESEL", 5, 2021, 50000, 1000000, 5000000,
                "Bán tải mạnh mẽ, đi địa hình tốt.", List.of("Camera lùi", "Thùng sau rộng"), 10.9804, 106.6519);
        vehicle(owner2, "Yamaha", "Motorbike", "Exciter 155", "59X1-678.90", "Xanh GP", "MANUAL", "GASOLINE", 2, 2022, 9000, 150000, 1000000,
                "Xe côn tay thể thao.", List.of("Mũ bảo hiểm"), 10.7872, 106.6712);

        log.info("Đã tạo {} user, {} xe mẫu (mật khẩu 123456). Admin: {}", users.count(), vehicles.count(), admin.getEmail());
    }

    private User user(String fullName, String email, String phone, String role) {
        User u = new User();
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPhone(phone);
        u.setPasswordHash(encoder.encode("123456"));
        u.setStatus("ACTIVE");
        u.setEmailVerified(true);
        u.setRole(roles.findByName(role).orElseThrow());
        u = users.save(u);
        UserProfile p = new UserProfile();
        p.setUserId(u.getId());
        profiles.save(p);
        return u;
    }

    private void vehicle(User owner, String brand, String category, String model, String plate, String color, String transmission,
                         String fuel, int seats, int year, int mileage, long price, long deposit, String description,
                         List<String> featureNames, double lat, double lng) {
        Brand b = brands.findByNameIgnoreCase(brand).orElseThrow();
        Category c = categories.findByNameIgnoreCase(category).orElseThrow();
        Vehicle v = new Vehicle();
        v.setOwnerId(owner.getId());
        v.setBrand(b);
        v.setCategory(c);
        v.setModel(model);
        v.setLicensePlate(plate);
        v.setColor(color);
        v.setTransmission(transmission);
        v.setFuelType(fuel);
        v.setSeats((short) seats);
        v.setYear((short) year);
        v.setMileage(mileage);
        v.setPricePerDay(BigDecimal.valueOf(price));
        v.setSecurityDeposit(BigDecimal.valueOf(deposit));
        v.setDescription(description);
        v.setStatus("ACTIVE");
        v.setAverageRating(BigDecimal.ZERO);
        v.setTotalReviews(0);
        v = vehicles.save(v);

        String text = (brand + " " + model).replace(' ', '+');
        for (short i = 0; i < 2; i++) {
            VehicleImage img = new VehicleImage();
            img.setVehicleId(v.getId());
            img.setImageUrl("https://placehold.co/800x500?text=" + text + "+" + (i + 1));
            img.setPrimaryImage(i == 0);
            img.setDisplayOrder(i);
            images.save(img);
        }
        for (String f : featureNames) {
            VehicleFeature vf = new VehicleFeature();
            vf.setVehicleId(v.getId());
            vf.setFeatureName(f);
            features.save(vf);
        }
        VehicleLocation l = new VehicleLocation();
        l.setVehicleId(v.getId());
        l.setLatitude(BigDecimal.valueOf(lat));
        l.setLongitude(BigDecimal.valueOf(lng));
        l.setSpeed(BigDecimal.ZERO);
        l.setHeading(BigDecimal.ZERO);
        l.setAccuracy(BigDecimal.ZERO);
        l.setLastUpdated(LocalDateTime.now());
        locations.save(l);

        MaintenanceRecord m = new MaintenanceRecord();
        m.setVehicleId(v.getId());
        m.setMaintenanceType("Thay dầu định kỳ");
        m.setDescription("Bảo dưỡng định kỳ");
        m.setCost(BigDecimal.valueOf(500000));
        m.setPerformedAt(LocalDateTime.now().minusMonths(2));
        m.setNextDueAt(LocalDateTime.now().plusMonths(4));
        maintenance.save(m);
    }
}
