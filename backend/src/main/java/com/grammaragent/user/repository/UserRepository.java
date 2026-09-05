package com.grammaragent.user.repository;

import com.grammaragent.user.entity.User;

import java.util.Optional;

public interface UserRepository {

    Optional<User> findByEmailIgnoreCase(String normalizedEmail);

    Optional<User> findById(Long userId);

    User insert(User user);

    void update(User user);
}
