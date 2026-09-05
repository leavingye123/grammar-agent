package com.grammaragent.learning.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.grammaragent.common.persistence.BaseEntity;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.OffsetDateTime;

@Getter
@Setter
@NoArgsConstructor
@TableName("user_learning_progress")
public class UserLearningProgress extends BaseEntity {

    private Long userId;
    private Long grammarPointId;
    private Integer masteryScore;
    private Integer totalQuestions;
    private Integer correctQuestions;
    private OffsetDateTime lastStudyAt;
}

