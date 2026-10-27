package com.vehiclerental.vehicle;

import com.vehiclerental.common.ApiResponse;
import com.vehiclerental.repository.BrandRepository;
import com.vehiclerental.repository.CategoryRepository;
import java.util.List;
import org.springframework.data.domain.Sort;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Danh mục hãng xe / loại xe (công khai) – dùng cho dropdown trong form đăng xe và bộ lọc. */
@RestController
@RequestMapping("/api")
public class CatalogController {

    public record BrandDto(Long id, String name, String country, String logoUrl) {}

    public record CategoryDto(Long id, String name, String description) {}

    private final BrandRepository brands;
    private final CategoryRepository categories;

    public CatalogController(BrandRepository brands, CategoryRepository categories) {
        this.brands = brands;
        this.categories = categories;
    }

    @GetMapping("/brands")
    public ApiResponse<List<BrandDto>> brands() {
        return ApiResponse.ok(brands.findAll(Sort.by("name")).stream()
                .map(b -> new BrandDto(b.getId(), b.getName(), b.getCountry(), b.getLogoUrl())).toList());
    }

    @GetMapping("/categories")
    public ApiResponse<List<CategoryDto>> categories() {
        return ApiResponse.ok(categories.findAll(Sort.by("name")).stream()
                .map(c -> new CategoryDto(c.getId(), c.getName(), c.getDescription())).toList());
    }
}
