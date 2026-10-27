package com.vehiclerental.common;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public final class SecurityUtils {
    private SecurityUtils() {}

    /** Người đang đăng nhập; ném 401 nếu chưa đăng nhập. */
    public static AuthPrincipal current() {
        AuthPrincipal p = currentOrNull();
        if (p == null) throw AppException.unauthorized("Bạn chưa đăng nhập");
        return p;
    }

    public static AuthPrincipal currentOrNull() {
        Authentication a = SecurityContextHolder.getContext().getAuthentication();
        if (a != null && a.getPrincipal() instanceof AuthPrincipal p) return p;
        return null;
    }
}
