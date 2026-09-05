package com.grammaragent.user.mapper;

import com.grammaragent.user.dto.UserProfileResponse;
import com.grammaragent.user.entity.User;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface UserProfileMapper {

    UserProfileResponse toProfileResponse(User user);
}
