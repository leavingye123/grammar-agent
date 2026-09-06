package com.grammaragent.learning.repository;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.grammaragent.learning.entity.UserStreak;
import com.grammaragent.learning.mapper.UserStreakMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MyBatisUserStreakRepository implements UserStreakRepository {

    private final UserStreakMapper mapper;

    @Override
    public Optional<UserStreak> findByUserId(Long userId) {
        return Optional.ofNullable(mapper.selectOne(Wrappers.<UserStreak>lambdaQuery()
                .eq(UserStreak::getUserId, userId)));
    }
}
