package com.vehiclerental.audit;

import com.vehiclerental.common.ApiResponse;
import com.vehiclerental.common.PageResponse;
import com.vehiclerental.entity.AuditLog;
import com.vehiclerental.repository.AuditLogRepository;
import com.vehiclerental.repository.UserRepository;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** Admin xem nhật ký hệ thống: GET /api/admin/audit-logs?entityType=&action=&page=0&size=20 */
@RestController
@RequestMapping("/api/admin/audit-logs")
public class AuditController {

    public record AuditLogDto(Long id, UUID userId, String userEmail, String action, String entityType, String entityId,
                              Map<String, Object> oldData, Map<String, Object> newData, String ipAddress, LocalDateTime createdAt) {}

    private final AuditLogRepository logs;
    private final UserRepository users;

    public AuditController(AuditLogRepository logs, UserRepository users) {
        this.logs = logs;
        this.users = users;
    }

    @GetMapping
    public ApiResponse<PageResponse<AuditLogDto>> list(@RequestParam(required = false) String entityType,
                                                       @RequestParam(required = false) String action,
                                                       @RequestParam(defaultValue = "0") int page,
                                                       @RequestParam(defaultValue = "20") int size) {
        String et = entityType == null || entityType.isBlank() ? null : entityType.trim();
        String ac = action == null || action.isBlank() ? null : action.trim();
        Page<AuditLog> result = logs.search(et, ac, PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 100)));
        Map<UUID, String> emails = new HashMap<>();
        Page<AuditLogDto> dtos = result.map(a -> new AuditLogDto(a.getId(), a.getUserId(),
                a.getUserId() == null ? null : emails.computeIfAbsent(a.getUserId(),
                        id -> users.findById(id).map(u -> u.getEmail()).orElse(null)),
                a.getAction(), a.getEntityType(), a.getEntityId(), a.getOldData(), a.getNewData(), a.getIpAddress(), a.getCreatedAt()));
        return ApiResponse.ok(PageResponse.of(dtos));
    }
}
