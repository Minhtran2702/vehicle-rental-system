package com.vehiclerental.common;

import java.util.UUID;

/**
 * Kiểm tra chủ sở hữu tài nguyên, dùng chung cho mọi module (xe, đơn đặt xe, địa chỉ...).
 * Cách dùng trong service:
 *   Ownership.requireOwnerOrAdmin(vehicle.getOwnerId(), "xe này");   // chủ xe hoặc admin
 *   Ownership.requireOwner(address.getUserId(), "địa chỉ này");     // chỉ chính chủ
 *   if (Ownership.canAccess(booking.getCustomerId(), ownerId)) ...   // một trong các bên liên quan hoặc admin
 * Không đúng chủ thì trả 403; không tìm thấy tài nguyên thì service tự trả 404.
 */
public final class Ownership {
    private Ownership() {}

    /** Người đang đăng nhập là một trong các chủ (hoặc là admin). */
    public static boolean canAccess(UUID... ownerIds) {
        AuthPrincipal me = SecurityUtils.current();
        if (me.isAdmin()) return true;
        for (UUID id : ownerIds) {
            if (id != null && id.equals(me.id())) return true;
        }
        return false;
    }

    /** Chỉ chính chủ (admin cũng không qua). */
    public static void requireOwner(UUID ownerId, String what) {
        if (ownerId == null || !ownerId.equals(SecurityUtils.current().id())) {
            throw AppException.forbidden("Bạn không có quyền với " + what);
        }
    }

    /** Chính chủ hoặc admin. */
    public static void requireOwnerOrAdmin(UUID ownerId, String what) {
        if (!canAccess(ownerId)) throw AppException.forbidden("Bạn không có quyền với " + what);
    }
}
