package com.vehiclerental.auth;

import com.vehiclerental.common.AuthPrincipal;
import com.vehiclerental.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/** Tạo và kiểm tra access token (JWT). Refresh token là chuỗi ngẫu nhiên lưu trong bảng refresh_tokens. */
@Service
public class JwtService {

    private final SecretKey key;
    private final long accessMinutes;
    private final long refreshDays;

    public JwtService(@Value("${app.jwt.secret}") String secret,
                      @Value("${app.jwt.access-minutes}") long accessMinutes,
                      @Value("${app.jwt.refresh-days}") long refreshDays) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessMinutes = accessMinutes;
        this.refreshDays = refreshDays;
    }

    public String createAccessToken(User u) {
        Instant now = Instant.now();
        return Jwts.builder()
                .subject(u.getId().toString())
                .claim("email", u.getEmail())
                .claim("role", u.getRole().getName())
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusSeconds(accessMinutes * 60)))
                .signWith(key)
                .compact();
    }

    /** Ném JwtException hoặc IllegalArgumentException nếu token sai / hết hạn. */
    public AuthPrincipal parse(String token) {
        Claims c = Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
        return new AuthPrincipal(UUID.fromString(c.getSubject()), c.get("email", String.class), c.get("role", String.class));
    }

    public long refreshDays() {
        return refreshDays;
    }

    public static boolean isInvalid(Exception e) {
        return e instanceof JwtException || e instanceof IllegalArgumentException;
    }
}
