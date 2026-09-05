package com.grammaragent.user.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum UserStatus {
    ACTIVE("ACTIVE"),
    DISABLED("DISABLED"),
    LOCKED("LOCKED");

    @EnumValue
    @JsonValue
    private final String value;
}

