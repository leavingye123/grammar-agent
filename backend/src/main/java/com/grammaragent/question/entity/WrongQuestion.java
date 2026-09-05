package com.grammaragent.question.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.grammaragent.common.persistence.BaseEntity;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.OffsetDateTime;

@Getter
@Setter
@NoArgsConstructor
@TableName("wrong_questions")
public class WrongQuestion extends BaseEntity {

    private Long userId;
    private Long questionId;
    private Integer wrongCount;
    private OffsetDateTime lastWrongAt;
    private OffsetDateTime nextReviewAt;
    private Boolean mastered;
}

