package com.grammaragent.learning.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.grammaragent.common.persistence.BaseEntity;
import com.grammaragent.learning.enums.LessonAttemptStatus;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.OffsetDateTime;

@Getter
@Setter
@NoArgsConstructor
@TableName("lesson_attempts")
public class LessonAttempt extends BaseEntity {

    private Long userId;
    private Long lessonId;
    private LessonAttemptStatus status;
    private OffsetDateTime startedAt;
    private OffsetDateTime completedAt;
    private Integer totalCount;
    private Integer correctCount;
    private Integer score;
    private Integer xpEarned;
}
