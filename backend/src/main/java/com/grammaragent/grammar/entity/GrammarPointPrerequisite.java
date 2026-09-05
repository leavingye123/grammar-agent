package com.grammaragent.grammar.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.grammaragent.common.persistence.BaseEntity;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@TableName("grammar_point_prerequisites")
public class GrammarPointPrerequisite extends BaseEntity {

    private Long grammarPointId;
    private Long prerequisiteGrammarPointId;
}

