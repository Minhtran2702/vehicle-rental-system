package com.vehiclerental.vehicle.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;

public record FeaturesRequest(@NotNull(message = "Thiếu danh sách tiện ích") @Size(max = 30, message = "Tối đa 30 tiện ích") List<String> features) {
}
