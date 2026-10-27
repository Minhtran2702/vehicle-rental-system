package com.vehiclerental.audit;

import com.vehiclerental.common.AuthPrincipal;
import com.vehiclerental.common.SecurityUtils;
import com.vehiclerental.entity.AuditLog;
import com.vehiclerental.repository.AuditLogRepository;
import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * Ghi nhật ký audit cho thao tác nhạy cảm. Dùng chung cho cả nhóm:
 *   auditService.log("VEHICLE_CREATE", "vehicle", vehicle.getId(), null, Map.of("plate", "51K-123.45"));
 * Tự lấy người thực hiện và địa chỉ IP từ request hiện tại. Lỗi khi ghi log không làm hỏng thao tác chính.
 */
@Service
public class AuditService {

    private static final Logger log = LoggerFactory.getLogger(AuditService.class);
    private final AuditLogRepository repo;

    public AuditService(AuditLogRepository repo) {
        this.repo = repo;
    }

    public void log(String action, String entityType, Object entityId, Map<String, Object> oldData, Map<String, Object> newData) {
        AuthPrincipal p = SecurityUtils.currentOrNull();
        log(p == null ? null : p.id(), action, entityType, entityId, oldData, newData);
    }

    public void log(UUID userId, String action, String entityType, Object entityId, Map<String, Object> oldData, Map<String, Object> newData) {
        try {
            AuditLog a = new AuditLog();
            a.setUserId(userId);
            a.setAction(action);
            a.setEntityType(entityType);
            a.setEntityId(entityId == null ? null : entityId.toString());
            a.setOldData(oldData);
            a.setNewData(newData);
            a.setIpAddress(clientIp());
            repo.save(a);
        } catch (RuntimeException e) {
            log.warn("Không ghi được audit log {}: {}", action, e.getMessage());
        }
    }

    private String clientIp() {
        try {
            if (RequestContextHolder.getRequestAttributes() instanceof ServletRequestAttributes attrs) {
                HttpServletRequest r = attrs.getRequest();
                String fwd = r.getHeader("X-Forwarded-For");
                String ip = (fwd != null && !fwd.isBlank()) ? fwd.split(",")[0].trim() : r.getRemoteAddr();
                return ip != null && ip.length() > 45 ? ip.substring(0, 45) : ip;
            }
        } catch (RuntimeException ignored) {
            // không có request (ví dụ chạy từ seed)
        }
        return null;
    }
}
