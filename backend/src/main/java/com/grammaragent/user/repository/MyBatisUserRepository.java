package com.grammaragent.user.repository;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.grammaragent.user.entity.User;
import com.grammaragent.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MyBatisUserRepository implements UserRepository {

    private final UserMapper userMapper;

    @Override
    public Optional<User> findByEmailIgnoreCase(String normalizedEmail) {
        User user = userMapper.selectOne(Wrappers.<User>query()
                .apply("LOWER(email) = {0}", normalizedEmail)
                .last("LIMIT 1"));
        return Optional.ofNullable(user);
    }

    @Override
    public Optional<User> findById(Long userId) {
        return Optional.ofNullable(userMapper.selectById(userId));
    }

    @Override
    public User insert(User user) {
        userMapper.insert(user);
        return user;
    }

    @Override
    public void update(User user) {
        userMapper.updateById(user);
    }
}
