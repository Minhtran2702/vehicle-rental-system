package com.vehiclerental.common;

/** Che dữ liệu nhạy cảm (CCCD, GPLX, số điện thoại) khi trả cho người không có quyền xem đầy đủ. */
public final class DataMasking {
    private DataMasking() {}

    /** "079123456789" -> "*********789": giữ 3 ký tự cuối. */
    public static String maskId(String s) {
        if (s == null || s.isBlank()) return null;
        String t = s.trim();
        if (t.length() <= 3) return "***";
        return "*".repeat(t.length() - 3) + t.substring(t.length() - 3);
    }

    /** "0912345678" -> "******5678": giữ 4 số cuối. */
    public static String maskPhone(String s) {
        if (s == null || s.isBlank()) return null;
        String t = s.trim();
        if (t.length() <= 4) return "***";
        return "*".repeat(t.length() - 4) + t.substring(t.length() - 4);
    }
}
