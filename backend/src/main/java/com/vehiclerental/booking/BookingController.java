package com.vehiclerental.booking;

import com.vehiclerental.booking.dto.BookingDtos.Availability;
import com.vehiclerental.booking.dto.BookingDtos.BookingDto;
import com.vehiclerental.booking.dto.BookingDtos.CreateBookingRequest;
import com.vehiclerental.booking.dto.BookingDtos.Quote;
import com.vehiclerental.booking.dto.BookingDtos.QuoteRequest;
import com.vehiclerental.common.ApiResponse;
import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Đặt xe. Tất cả cần đăng nhập. Giờ gửi dạng ISO, ví dụ 2026-12-01T09:00:00. */
@RestController
@RequestMapping("/api/bookings")
public class BookingController {

    private final BookingService service;

    public BookingController(BookingService service) {
        this.service = service;
    }

    /** Xe có trống trong khoảng giờ này không + danh sách lịch bận. from/to có thể bỏ trống để chỉ xem lịch bận. */
    @GetMapping("/availability")
    public ApiResponse<Availability> availability(@RequestParam UUID vehicleId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime to) {
        return ApiResponse.ok(service.availability(vehicleId, from, to));
    }

    @PostMapping("/quote")
    public ApiResponse<Quote> quote(@Valid @RequestBody QuoteRequest req) {
        return ApiResponse.ok(service.quote(req));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<BookingDto> create(@Valid @RequestBody CreateBookingRequest req) {
        return ApiResponse.ok("Đã gửi yêu cầu đặt xe", service.create(req));
    }

    @GetMapping("/mine")
    public ApiResponse<List<BookingDto>> mine() {
        return ApiResponse.ok(service.mine());
    }

    @GetMapping("/{id}")
    public ApiResponse<BookingDto> get(@PathVariable UUID id) {
        return ApiResponse.ok(service.get(id));
    }
}
