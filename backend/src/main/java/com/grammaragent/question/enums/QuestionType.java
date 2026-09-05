package com.grammaragent.question.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum QuestionType {
    SINGLE_CHOICE("SINGLE_CHOICE"),
    MULTIPLE_CHOICE("MULTIPLE_CHOICE"),
    FILL_BLANK("FILL_BLANK"),
    SENTENCE_ORDER("SENTENCE_ORDER"),
    TRUE_FALSE("TRUE_FALSE"),
    CORRECTION("CORRECTION");

    @EnumValue
    @JsonValue
    private final String value;
}

