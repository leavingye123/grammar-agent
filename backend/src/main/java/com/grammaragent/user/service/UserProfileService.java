package com.grammaragent.user.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.user.dto.UserProfileResponse;
import com.grammaragent.user.mapper.UserProfileMapper;
import com.grammaragent.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserProfileService {

    private final UserRepository userRepository;
    private final UserProfileMapper userProfileMapper;

    public UserProfileResponse getProfile(Long userId) {
        return userRepository.findById(userId)
                .map(userProfileMapper::toProfileResponse)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
    }
}
