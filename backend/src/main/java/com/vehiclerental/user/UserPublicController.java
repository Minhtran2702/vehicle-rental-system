package com.vehiclerental.user;

import com.vehiclerental.common.ApiResponse;
import com.vehiclerental.user.dto.UserCardDto;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Xem hồ sơ người khác (đã che CCCD, GPLX, SĐT, email). Chính chủ và admin thấy đầy đủ. */
@RestController
@RequestMapping("/api/users")
public class UserPublicController {

    private final UserService service;

    public UserPublicController(UserService service) {
        this.service = service;
    }

    @GetMapping("/{id}/card")
    public ApiResponse<UserCardDto> card(@PathVariable UUID id) {
        return ApiResponse.ok(service.card(id));
    }
}
