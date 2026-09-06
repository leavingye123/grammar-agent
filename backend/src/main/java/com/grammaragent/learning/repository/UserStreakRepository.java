package com.grammaragent.learning.repository;

import com.grammaragent.learning.entity.UserStreak;

import java.util.Optional;

public interface UserStreakRepository {

    Optional<UserStreak> findByUserId(Long userId);
}
