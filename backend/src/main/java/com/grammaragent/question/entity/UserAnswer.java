package com.grammaragent.question.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.databind.JsonNode;
import com.grammaragent.common.persistence.BaseEntity;
import com.grammaragent.common.persistence.JsonNodeTypeHandler;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.OffsetDateTime;

@Getter
@Setter
@NoArgsConstructor
@TableName(value = "user_answers", autoResultMap = true)
public class UserAnswer extends BaseEntity {

    private Long userId;
    private Long questionId;

    @TableField(typeHandler = JsonNodeTypeHandler.class)
    private JsonNode answer;

    private Boolean isCorrect;
    private Integer durationMs;
    private OffsetDateTime answeredAt;
}
