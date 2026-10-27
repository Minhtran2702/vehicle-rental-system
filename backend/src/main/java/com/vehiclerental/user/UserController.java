package com.vehiclerental.user;

import com.vehiclerental.common.ApiResponse;
import com.vehiclerental.user.dto.AddressDto;
import com.vehiclerental.user.dto.AddressRequest;
import com.vehiclerental.user.dto.ProfileDto;
import com.vehiclerental.user.dto.UpdateProfileRequest;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users/me")
public class UserController {

    private final UserService service;

    public UserController(UserService service) {
        this.service = service;
    }

    @GetMapping
    public ApiResponse<ProfileDto> profile() {
        return ApiResponse.ok(service.getProfile());
    }

    @PutMapping
    public ApiResponse<ProfileDto> updateProfile(@Valid @RequestBody UpdateProfileRequest req) {
        return ApiResponse.ok("Đã lưu hồ sơ", service.updateProfile(req));
    }

    @GetMapping("/addresses")
    public ApiResponse<List<AddressDto>> addresses() {
        return ApiResponse.ok(service.listAddresses());
    }

    @PostMapping("/addresses")
    public ApiResponse<List<AddressDto>> createAddress(@Valid @RequestBody AddressRequest req) {
        return ApiResponse.ok("Đã thêm địa chỉ", service.createAddress(req));
    }

    @PutMapping("/addresses/{id}")
    public ApiResponse<List<AddressDto>> updateAddress(@PathVariable Long id, @Valid @RequestBody AddressRequest req) {
        return ApiResponse.ok("Đã lưu địa chỉ", service.updateAddress(id, req));
    }

    @DeleteMapping("/addresses/{id}")
    public ApiResponse<List<AddressDto>> deleteAddress(@PathVariable Long id) {
        return ApiResponse.ok("Đã xóa địa chỉ", service.deleteAddress(id));
    }
}
