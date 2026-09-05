package com.grammaragent.grammar.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.databind.JsonNode;
import com.grammaragent.common.persistence.BaseEntity;
import com.grammaragent.common.persistence.JsonNodeTypeHandler;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@TableName(value = "grammar_points", autoResultMap = true)
public class GrammarPoint extends BaseEntity {

    private Long chapterId;
    private String code;
    private String title;
    private String description;
    private String grammarRule;

    @TableField(typeHandler = JsonNodeTypeHandler.class)
    private JsonNode examples;

    @TableField(typeHandler = JsonNodeTypeHandler.class)
    private JsonNode commonErrors;

    private Integer difficulty;
    private Integer sortOrder;
    private Boolean enabled;
}
