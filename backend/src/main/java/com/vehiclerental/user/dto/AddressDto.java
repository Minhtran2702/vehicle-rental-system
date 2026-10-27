package com.vehiclerental.user.dto;

public record AddressDto(Long id, String label, String addressLine, String ward, String district, String city,
                         String country, String postalCode, boolean defaultAddress) {
}
