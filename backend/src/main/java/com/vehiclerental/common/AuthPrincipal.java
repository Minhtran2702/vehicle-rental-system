package com.vehiclerental.common;

import java.util.UUID;

/** Người đang đăng nhập (lấy từ JWT). role là "CUSTOMER" hoặc "ADMIN". */
public record AuthPrincipal(UUID id, String email, String role) {
    public boolean isAdmin() {
        return "ADMIN".equals(role);
    }
}
