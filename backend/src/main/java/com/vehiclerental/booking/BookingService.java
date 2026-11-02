package com.vehiclerental.booking;

import com.vehiclerental.audit.AuditService;
import com.vehiclerental.booking.dto.BookingDtos.Availability;
import com.vehiclerental.booking.dto.BookingDtos.BookingDto;
import com.vehiclerental.booking.dto.BookingDtos.BusyPeriod;
import com.vehiclerental.booking.dto.BookingDtos.CreateBookingRequest;
import com.vehiclerental.booking.dto.BookingDtos.Quote;
import com.vehiclerental.booking.dto.BookingDtos.QuoteRequest;
import com.vehiclerental.booking.dto.BookingDtos.StatusHistoryDto;
import com.vehiclerental.common.AppException;
import com.vehiclerental.common.Ownership;
import com.vehiclerental.common.SecurityUtils;
import com.vehiclerental.entity.Booking;
import com.vehiclerental.entity.BookingStatusHistory;
import com.vehiclerental.entity.Coupon;
import com.vehiclerental.entity.Notification;
import com.vehiclerental.entity.Vehicle;
import com.vehiclerental.entity.VehicleImage;
import com.vehiclerental.repository.BookingRepository;
import com.vehiclerental.repository.BookingStatusHistoryRepository;
import com.vehiclerental.repository.CouponRepository;
import com.vehiclerental.repository.NotificationRepository;
import com.vehiclerental.repository.UserRepository;
import com.vehiclerental.repository.VehicleImageRepository;
import com.vehiclerental.repository.VehicleRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Đặt xe: kiểm tra xe trống (CV50), tính giá + coupon (CV54), tạo đơn + xem đơn của mình (CV58).
 * Quy tắc:
 *  - Chỉ đặt được xe ACTIVE (không đặt xe INACTIVE / MAINTENANCE) và không đặt xe của chính mình.
 *  - Đơn PENDING / CONFIRMED / IN_PROGRESS giữ chỗ; hai đơn giữ chỗ không được chồng giờ nhau.
 *  - Số ngày = làm tròn lên theo mỗi 24 giờ (tối thiểu 1). Thuế VAT 10% tính trên (tạm tính - giảm giá).
 *  - Tiền cọc của xe hiển thị riêng, không cộng vào tổng tiền thuê.
 */
@Service
public class BookingService {

    /** Các trạng thái đang giữ xe. */
    static final List<String> HOLDING = List.of("PENDING", "CONFIRMED", "IN_PROGRESS");
    static final BigDecimal VAT = new BigDecimal("0.10");

    private final BookingRepository bookings;
    private final BookingStatusHistoryRepository history;
    private final VehicleRepository vehicles;
    private final VehicleImageRepository images;
    private final CouponRepository coupons;
    private final NotificationRepository notifications;
    private final UserRepository users;
    private final AuditService audit;

    public BookingService(BookingRepository bookings, BookingStatusHistoryRepository history, VehicleRepository vehicles,
                          VehicleImageRepository images, CouponRepository coupons, NotificationRepository notifications,
                          UserRepository users, AuditService audit) {
        this.bookings = bookings;
        this.history = history;
        this.vehicles = vehicles;
        this.images = images;
        this.coupons = coupons;
        this.notifications = notifications;
        this.users = users;
        this.audit = audit;
    }

    // ---------- CV50: kiểm tra xe trống ----------

    @Transactional(readOnly = true)
    public Availability availability(UUID vehicleId, LocalDateTime from, LocalDateTime to) {
        Vehicle v = vehicles.findById(vehicleId).orElseThrow(() -> AppException.notFound("Không tìm thấy xe"));
        List<BusyPeriod> busy = bookings.findBusy(vehicleId, HOLDING, LocalDateTime.now()).stream()
                .map(b -> new BusyPeriod(b.getPickupDatetime(), b.getReturnDatetime())).toList();
        String reason = unavailableReason(v, from, to, null);
        return new Availability(reason == null, reason, busy);
    }

    /** null nếu đặt được, ngược lại là lý do. `me` != null thì kiểm tra thêm "xe của chính mình". */
    private String unavailableReason(Vehicle v, LocalDateTime from, LocalDateTime to, UUID me) {
        if ("MAINTENANCE".equals(v.getStatus())) return "Xe đang bảo dưỡng";
        if (!"ACTIVE".equals(v.getStatus())) return "Xe hiện không cho thuê";
        if (me != null && me.equals(v.getOwnerId())) return "Bạn không thể thuê xe của chính mình";
        if (from != null && to != null) {
            if (!to.isAfter(from)) return "Giờ trả xe phải sau giờ nhận xe";
            if (from.isBefore(LocalDateTime.now())) return "Giờ nhận xe phải ở tương lai";
            if (bookings.existsOverlap(v.getId(), HOLDING, from, to)) return "Xe đã có người đặt trong khoảng thời gian này";
        }
        return null;
    }

    // ---------- CV54: tính giá + coupon ----------

    @Transactional(readOnly = true)
    public Quote quote(QuoteRequest req) {
        Vehicle v = vehicles.findById(req.vehicleId()).orElseThrow(() -> AppException.notFound("Không tìm thấy xe"));
        return price(v, req.pickupDatetime(), req.returnDatetime(), req.couponCode()).quote;
    }

    private record Priced(Quote quote, Coupon coupon) {}

    private Priced price(Vehicle v, LocalDateTime from, LocalDateTime to, String couponCode) {
        if (!to.isAfter(from)) throw AppException.badRequest("Giờ trả xe phải sau giờ nhận xe");
        long minutes = Duration.between(from, to).toMinutes();
        int days = (int) Math.max(1, (minutes + 1439) / 1440);
        BigDecimal subtotal = v.getPricePerDay().multiply(BigDecimal.valueOf(days)).setScale(0, RoundingMode.HALF_UP);

        Coupon coupon = null;
        BigDecimal discount = BigDecimal.ZERO;
        if (couponCode != null && !couponCode.isBlank()) {
            coupon = coupons.findByCodeIgnoreCase(couponCode.trim()).orElseThrow(() -> AppException.badRequest("Mã giảm giá không tồn tại"));
            discount = discountOf(coupon, subtotal);
        }
        BigDecimal tax = subtotal.subtract(discount).multiply(VAT).setScale(0, RoundingMode.HALF_UP);
        BigDecimal total = subtotal.subtract(discount).add(tax);
        Quote q = new Quote(v.getId(), vehicleName(v), primaryImage(v), v.getPricePerDay(), days, subtotal, coupon == null ? null : coupon.getCode(),
                discount, tax, total, v.getSecurityDeposit());
        return new Priced(q, coupon);
    }

    private BigDecimal discountOf(Coupon c, BigDecimal subtotal) {
        LocalDateTime now = LocalDateTime.now();
        if (!c.isActive()) throw AppException.badRequest("Mã giảm giá đã ngừng áp dụng");
        if (now.isBefore(c.getValidFrom()) || now.isAfter(c.getValidTo())) throw AppException.badRequest("Mã giảm giá đã hết hạn hoặc chưa đến ngày áp dụng");
        if (c.getUsedCount() >= c.getUsageLimit()) throw AppException.badRequest("Mã giảm giá đã hết lượt dùng");
        if (subtotal.compareTo(c.getMinOrderAmount()) < 0) {
            throw AppException.badRequest("Đơn tối thiểu " + c.getMinOrderAmount().setScale(0, RoundingMode.HALF_UP).toPlainString() + " đ để dùng mã này");
        }
        BigDecimal d;
        if ("PERCENT".equals(c.getDiscountType())) {
            d = subtotal.multiply(c.getDiscountValue()).divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
            if (c.getMaxDiscount() != null && d.compareTo(c.getMaxDiscount()) > 0) d = c.getMaxDiscount();
        } else {
            d = c.getDiscountValue();
        }
        return d.min(subtotal).setScale(0, RoundingMode.HALF_UP);
    }

    // ---------- CV58: tạo đơn, xem đơn của mình ----------

    @Transactional
    public BookingDto create(CreateBookingRequest req) {
        UUID me = SecurityUtils.current().id();
        // khoá dòng xe để hai người không đặt trùng cùng lúc
        Vehicle v = vehicles.lockById(req.vehicleId()).orElseThrow(() -> AppException.notFound("Không tìm thấy xe"));
        String reason = unavailableReason(v, req.pickupDatetime(), req.returnDatetime(), me);
        if (reason != null) throw AppException.conflict(reason);

        Priced p = price(v, req.pickupDatetime(), req.returnDatetime(), req.couponCode());
        Booking b = new Booking();
        b.setCustomerId(me);
        b.setVehicleId(v.getId());
        b.setPickupDatetime(req.pickupDatetime());
        b.setReturnDatetime(req.returnDatetime());
        b.setPickupLocation(orDefault(req.pickupLocation(), "Nhận xe tại chủ xe"));
        b.setReturnLocation(orDefault(req.returnLocation(), "Trả xe tại chủ xe"));
        b.setTotalDays(p.quote.totalDays());
        b.setSubtotal(p.quote.subtotal());
        b.setDiscount(p.quote.discount());
        b.setTax(p.quote.tax());
        b.setTotalAmount(p.quote.totalAmount());
        b.setStatus("PENDING");
        if (p.coupon != null) {
            b.setCouponId(p.coupon.getId());
            p.coupon.setUsedCount(p.coupon.getUsedCount() + 1);
            coupons.save(p.coupon);
        }
        b = bookings.save(b);
        history.save(new BookingStatusHistory(b.getId(), "PENDING", me, "Khách tạo yêu cầu đặt xe"));

        Map<String, Object> snap = new LinkedHashMap<>();
        snap.put("vehicleId", v.getId().toString());
        snap.put("total", b.getTotalAmount());
        snap.put("status", "PENDING");
        audit.log("BOOKING_CREATE", "booking", b.getId(), null, snap);

        Notification n = new Notification();
        n.setUserId(v.getOwnerId());
        n.setTitle("Có yêu cầu đặt xe mới");
        n.setMessage("Xe " + vehicleName(v) + " vừa có yêu cầu đặt từ " + b.getPickupDatetime().toLocalDate() + " đến " + b.getReturnDatetime().toLocalDate() + ".");
        n.setType("BOOKING");
        notifications.save(n);
        return toDto(b, v, p.coupon == null ? null : p.coupon.getCode(), true);
    }

    @Transactional(readOnly = true)
    public List<BookingDto> mine() {
        UUID me = SecurityUtils.current().id();
        return bookings.findByCustomerIdOrderByCreatedAtDesc(me).stream()
                .map(b -> toDto(b, vehicles.findById(b.getVehicleId()).orElse(null), null, false)).toList();
    }

    /** Khách xem đơn của mình; chủ xe xem đơn của xe mình; admin xem tất cả. */
    @Transactional(readOnly = true)
    public BookingDto get(UUID id) {
        Booking b = bookings.findById(id).orElseThrow(() -> AppException.notFound("Không tìm thấy đơn đặt xe"));
        Vehicle v = vehicles.findById(b.getVehicleId()).orElse(null);
        if (!Ownership.canAccess(b.getCustomerId(), v == null ? null : v.getOwnerId())) throw AppException.forbidden("Bạn không có quyền xem đơn này");
        String code = b.getCouponId() == null ? null : coupons.findById(b.getCouponId()).map(Coupon::getCode).orElse(null);
        return toDto(b, v, code, true);
    }

    // ---------- helpers ----------

    private static String orDefault(String s, String d) {
        return s == null || s.isBlank() ? d : s.trim();
    }

    private String vehicleName(Vehicle v) {
        return v.getBrand().getName() + " " + v.getModel();
    }

    private String primaryImage(Vehicle v) {
        List<VehicleImage> imgs = images.findByVehicleIdOrderByDisplayOrderAscIdAsc(v.getId());
        return imgs.stream().filter(VehicleImage::isPrimaryImage).findFirst().or(() -> imgs.stream().findFirst()).map(VehicleImage::getImageUrl).orElse(null);
    }

    private BookingDto toDto(Booking b, Vehicle v, String couponCode, boolean withHistory) {
        String image = v == null ? null : primaryImage(v);
        String customerName = users.findById(b.getCustomerId()).map(u -> u.getFullName()).orElse(null);
        List<StatusHistoryDto> hist = withHistory
                ? history.findByBookingIdOrderByCreatedAtAsc(b.getId()).stream().map(h -> new StatusHistoryDto(h.getStatus(), h.getNote(), h.getCreatedAt())).toList()
                : List.of();
        return new BookingDto(b.getId(), b.getVehicleId(), v == null ? "(xe đã xoá)" : vehicleName(v), image, b.getCustomerId(), customerName,
                b.getPickupDatetime(), b.getReturnDatetime(), b.getPickupLocation(), b.getReturnLocation(), b.getTotalDays(),
                b.getSubtotal(), b.getDiscount(), b.getTax(), b.getTotalAmount(), v == null ? null : v.getSecurityDeposit(),
                couponCode, b.getStatus(), b.getCreatedAt(), hist);
    }
}
