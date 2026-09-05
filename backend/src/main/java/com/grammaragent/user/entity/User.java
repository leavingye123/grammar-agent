package com.grammaragent.user.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.grammaragent.common.persistence.BaseEntity;
import com.grammaragent.user.enums.UserStatus;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.OffsetDateTime;

@Getter
@Setter
@NoArgsConstructor
@TableName("users")
public class User extends BaseEntity {

    private String email;
    private String username;
    private String passwordHash;
    private String avatarUrl;
    private String nativeLanguage;
    private UserStatus status;
    private OffsetDateTime lastLoginAt;
}

