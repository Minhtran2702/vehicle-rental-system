package com.vehiclerental.auth;

import com.vehiclerental.auth.dto.AuthResponse;
import com.vehiclerental.auth.dto.LoginRequest;
import com.vehiclerental.auth.dto.RefreshRequest;
import com.vehiclerental.auth.dto.RegisterRequest;
import com.vehiclerental.auth.dto.TokenPair;
import com.vehiclerental.auth.dto.UserDto;
import com.vehiclerental.common.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService service;

    public AuthController(AuthService service) {
        this.service = service;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<UserDto> register(@Valid @RequestBody RegisterRequest req) {
        return ApiResponse.ok("Đăng ký thành công", service.register(req));
    }

    @PostMapping("/login")
    public ApiResponse<AuthResponse> login(@Valid @RequestBody LoginRequest req) {
        return ApiResponse.ok("Đăng nhập thành công", service.login(req));
    }

    @PostMapping("/refresh")
    public ApiResponse<TokenPair> refresh(@Valid @RequestBody RefreshRequest req) {
        return ApiResponse.ok(service.refresh(req));
    }

    @PostMapping("/logout")
    public ApiResponse<Void> logout(@Valid @RequestBody RefreshRequest req) {
        service.logout(req);
        return ApiResponse.ok("Đã đăng xuất", null);
    }
}
