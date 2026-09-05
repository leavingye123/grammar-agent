package com.grammaragent.lesson.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum LessonType {
    LEARNING("LEARNING"),
    PRACTICE("PRACTICE"),
    REVIEW("REVIEW");

    @EnumValue
    @JsonValue
    private final String value;
}

