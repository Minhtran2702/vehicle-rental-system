package com.vehiclerental.repository;

import com.vehiclerental.entity.Address;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AddressRepository extends JpaRepository<Address, Long> {
    List<Address> findByUserIdOrderByDefaultAddressDescIdAsc(UUID userId);

    Optional<Address> findByIdAndUserId(Long id, UUID userId);
}
