package com.vehiclerental.user;

import com.vehiclerental.common.AppException;
import com.vehiclerental.common.SecurityUtils;
import com.vehiclerental.entity.Address;
import com.vehiclerental.entity.User;
import com.vehiclerental.entity.UserProfile;
import com.vehiclerental.repository.AddressRepository;
import com.vehiclerental.repository.UserProfileRepository;
import com.vehiclerental.repository.UserRepository;
import com.vehiclerental.user.dto.AddressDto;
import com.vehiclerental.user.dto.AddressRequest;
import com.vehiclerental.user.dto.ProfileDto;
import com.vehiclerental.user.dto.UpdateProfileRequest;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Hồ sơ cá nhân và sổ địa chỉ. Mọi thao tác chỉ trên dữ liệu của CHÍNH người đang đăng nhập. */
@Service
public class UserService {

    private final UserRepository users;
    private final UserProfileRepository profiles;
    private final AddressRepository addresses;

    public UserService(UserRepository users, UserProfileRepository profiles, AddressRepository addresses) {
        this.users = users;
        this.profiles = profiles;
        this.addresses = addresses;
    }

    // ---------------- Hồ sơ ----------------
    @Transactional
    public ProfileDto getProfile() {
        User u = currentUser();
        return toDto(u, profileOf(u.getId()));
    }

    @Transactional
    public ProfileDto updateProfile(UpdateProfileRequest req) {
        User u = currentUser();
        u.setFullName(req.fullName().trim());
        u.setPhone(blankToNull(req.phone()));
        users.save(u);
        UserProfile p = profileOf(u.getId());
        p.setDateOfBirth(req.dateOfBirth());
        p.setGender(blankToNull(req.gender()));
        p.setBio(blankToNull(req.bio()));
        p.setAvatarUrl(blankToNull(req.avatarUrl()));
        p.setIdCardNumber(blankToNull(req.idCardNumber()));
        p.setDriverLicenseNumber(blankToNull(req.driverLicenseNumber()));
        profiles.save(p);
        return toDto(u, p);
    }

    private User currentUser() {
        return users.findById(SecurityUtils.current().id()).orElseThrow(() -> AppException.unauthorized("Tài khoản không tồn tại"));
    }

    private UserProfile profileOf(UUID userId) {
        return profiles.findByUserId(userId).orElseGet(() -> {
            UserProfile p = new UserProfile();
            p.setUserId(userId);
            return profiles.save(p);
        });
    }

    private ProfileDto toDto(User u, UserProfile p) {
        return new ProfileDto(u.getId(), u.getEmail(), u.getFullName(), u.getPhone(), u.getRole().getName(), p.getAvatarUrl(),
                p.getDateOfBirth(), p.getGender(), p.getBio(), p.getIdCardNumber(), p.getDriverLicenseNumber());
    }

    // ---------------- Sổ địa chỉ ----------------
    @Transactional(readOnly = true)
    public List<AddressDto> listAddresses() {
        return addresses.findByUserIdOrderByDefaultAddressDescIdAsc(SecurityUtils.current().id()).stream().map(this::toDto).toList();
    }

    @Transactional
    public List<AddressDto> createAddress(AddressRequest req) {
        UUID uid = SecurityUtils.current().id();
        Address a = new Address();
        a.setUserId(uid);
        apply(a, req);
        boolean first = addresses.findByUserIdOrderByDefaultAddressDescIdAsc(uid).isEmpty();
        a.setDefaultAddress(first || Boolean.TRUE.equals(req.defaultAddress()));
        if (a.isDefaultAddress()) clearDefault(uid);
        addresses.save(a);
        return listAddresses();
    }

    @Transactional
    public List<AddressDto> updateAddress(Long id, AddressRequest req) {
        UUID uid = SecurityUtils.current().id();
        Address a = addresses.findByIdAndUserId(id, uid).orElseThrow(() -> AppException.notFound("Không tìm thấy địa chỉ"));
        apply(a, req);
        if (Boolean.TRUE.equals(req.defaultAddress()) && !a.isDefaultAddress()) {
            clearDefault(uid);
            a.setDefaultAddress(true);
        }
        addresses.save(a);
        return listAddresses();
    }

    @Transactional
    public List<AddressDto> deleteAddress(Long id) {
        UUID uid = SecurityUtils.current().id();
        Address a = addresses.findByIdAndUserId(id, uid).orElseThrow(() -> AppException.notFound("Không tìm thấy địa chỉ"));
        boolean wasDefault = a.isDefaultAddress();
        addresses.delete(a);
        addresses.flush();
        if (wasDefault) {
            addresses.findByUserIdOrderByDefaultAddressDescIdAsc(uid).stream().findFirst().ifPresent(first -> {
                first.setDefaultAddress(true);
                addresses.save(first);
            });
        }
        return listAddresses();
    }

    private void clearDefault(UUID uid) {
        for (Address x : addresses.findByUserIdOrderByDefaultAddressDescIdAsc(uid)) {
            if (x.isDefaultAddress()) {
                x.setDefaultAddress(false);
                addresses.save(x);
            }
        }
    }

    private void apply(Address a, AddressRequest r) {
        a.setLabel(r.label().trim());
        a.setAddressLine(r.addressLine().trim());
        a.setWard(blankToNull(r.ward()));
        a.setDistrict(blankToNull(r.district()));
        a.setCity(r.city().trim());
        a.setCountry(r.country() == null || r.country().isBlank() ? "Việt Nam" : r.country().trim());
        a.setPostalCode(blankToNull(r.postalCode()));
    }

    private AddressDto toDto(Address a) {
        return new AddressDto(a.getId(), a.getLabel(), a.getAddressLine(), a.getWard(), a.getDistrict(), a.getCity(),
                a.getCountry(), a.getPostalCode(), a.isDefaultAddress());
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
