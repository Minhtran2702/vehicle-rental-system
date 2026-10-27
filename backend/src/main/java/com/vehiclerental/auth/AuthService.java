package com.vehiclerental.auth;

import com.vehiclerental.audit.AuditService;
import com.vehiclerental.auth.dto.AuthResponse;
import com.vehiclerental.auth.dto.LoginRequest;
import com.vehiclerental.auth.dto.RefreshRequest;
import com.vehiclerental.auth.dto.RegisterRequest;
import com.vehiclerental.auth.dto.TokenPair;
import com.vehiclerental.auth.dto.UserDto;
import com.vehiclerental.common.AppException;
import com.vehiclerental.entity.RefreshToken;
import com.vehiclerental.entity.Role;
import com.vehiclerental.entity.User;
import com.vehiclerental.entity.UserProfile;
import com.vehiclerental.repository.RefreshTokenRepository;
import com.vehiclerental.repository.RoleRepository;
import com.vehiclerental.repository.UserProfileRepository;
import com.vehiclerental.repository.UserRepository;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository users;
    private final RoleRepository roles;
    private final UserProfileRepository profiles;
    private final RefreshTokenRepository refreshTokens;
    private final PasswordEncoder encoder;
    private final JwtService jwt;
    private final AuditService audit;

    public AuthService(UserRepository users, RoleRepository roles, UserProfileRepository profiles,
                       RefreshTokenRepository refreshTokens, PasswordEncoder encoder, JwtService jwt, AuditService audit) {
        this.users = users;
        this.roles = roles;
        this.profiles = profiles;
        this.refreshTokens = refreshTokens;
        this.encoder = encoder;
        this.jwt = jwt;
        this.audit = audit;
    }

    /** Đăng ký tài khoản khách thuê (cũng đăng được xe cho thuê). Không tự đăng nhập. */
    @Transactional
    public UserDto register(RegisterRequest req) {
        String email = req.email().trim().toLowerCase();
        if (users.existsByEmailIgnoreCase(email)) throw AppException.conflict("Email đã được sử dụng");
        Role role = roles.findByName("CUSTOMER").orElseThrow(() -> new IllegalStateException("Thiếu vai trò CUSTOMER trong CSDL"));
        User u = new User();
        u.setRole(role);
        u.setFullName(req.fullName().trim());
        u.setEmail(email);
        u.setPhone(req.phone());
        u.setPasswordHash(encoder.encode(req.password()));
        u.setStatus("ACTIVE");
        u.setEmailVerified(false);
        u = users.save(u);
        UserProfile p = new UserProfile();
        p.setUserId(u.getId());
        profiles.save(p);
        audit.log(u.getId(), "USER_REGISTER", "user", u.getId(), null, Map.of("email", email));
        return toDto(u);
    }

    @Transactional
    public AuthResponse login(LoginRequest req) {
        User u = users.findByEmailIgnoreCase(req.email().trim()).orElse(null);
        if (u == null || !encoder.matches(req.password(), u.getPasswordHash())) {
            throw AppException.unauthorized("Sai email hoặc mật khẩu");
        }
        if (!"ACTIVE".equals(u.getStatus())) throw AppException.forbidden("Tài khoản đã bị khóa");
        return new AuthResponse(toDto(u), jwt.createAccessToken(u), newRefreshToken(u.getId()));
    }

    /** Đổi refresh token cũ lấy cặp token mới (token cũ bị thu hồi). */
    @Transactional
    public TokenPair refresh(RefreshRequest req) {
        RefreshToken rt = refreshTokens.findByToken(req.refreshToken())
                .orElseThrow(() -> AppException.unauthorized("Phiên đăng nhập không hợp lệ"));
        if (rt.isRevoked() || rt.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw AppException.unauthorized("Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại");
        }
        User u = users.findById(rt.getUserId()).orElseThrow(() -> AppException.unauthorized("Tài khoản không tồn tại"));
        if (!"ACTIVE".equals(u.getStatus())) throw AppException.forbidden("Tài khoản đã bị khóa");
        rt.setRevoked(true);
        refreshTokens.save(rt);
        return new TokenPair(jwt.createAccessToken(u), newRefreshToken(u.getId()));
    }

    @Transactional
    public void logout(RefreshRequest req) {
        refreshTokens.findByToken(req.refreshToken()).ifPresent(rt -> {
            rt.setRevoked(true);
            refreshTokens.save(rt);
        });
    }

    private String newRefreshToken(UUID userId) {
        RefreshToken rt = new RefreshToken();
        rt.setUserId(userId);
        rt.setToken(UUID.randomUUID() + "." + UUID.randomUUID());
        rt.setExpiresAt(LocalDateTime.now().plusDays(jwt.refreshDays()));
        rt.setRevoked(false);
        refreshTokens.save(rt);
        return rt.getToken();
    }

    public UserDto toDto(User u) {
        String avatar = profiles.findByUserId(u.getId()).map(UserProfile::getAvatarUrl).orElse(null);
        return new UserDto(u.getId(), u.getEmail(), u.getFullName(), u.getRole().getName(), avatar);
    }
}
