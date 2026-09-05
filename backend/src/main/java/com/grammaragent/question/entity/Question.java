package com.grammaragent.question.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.databind.JsonNode;
import com.grammaragent.common.persistence.BaseEntity;
import com.grammaragent.common.persistence.JsonNodeTypeHandler;
import com.grammaragent.question.enums.QuestionType;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@TableName(value = "questions", autoResultMap = true)
public class Question extends BaseEntity {

    private Long lessonId;
    private Long grammarPointId;
    private QuestionType questionType;
    private String questionContent;

    @TableField(typeHandler = JsonNodeTypeHandler.class)
    private JsonNode options;

    @TableField(typeHandler = JsonNodeTypeHandler.class)
    private JsonNode correctAnswer;

    private String explanation;
    private Integer difficulty;
    private Integer sortOrder;
    private Boolean enabled;
}
