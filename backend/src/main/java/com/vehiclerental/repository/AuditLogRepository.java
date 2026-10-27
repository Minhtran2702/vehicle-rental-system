package com.vehiclerental.repository;

import com.vehiclerental.entity.AuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    @Query("select a from AuditLog a "
            + "where (cast(:entityType as string) is null or a.entityType = :entityType) "
            + "and (cast(:action as string) is null or a.action = :action) "
            + "order by a.createdAt desc")
    Page<AuditLog> search(@Param("entityType") String entityType, @Param("action") String action, Pageable pageable);
}
