package com.grammaragent.learning.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.grammaragent.common.persistence.BaseEntity;
import com.grammaragent.learning.enums.LessonProgressStatus;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.OffsetDateTime;

@Getter
@Setter
@NoArgsConstructor
@TableName("user_lesson_progress")
public class UserLessonProgress extends BaseEntity {

    private Long userId;
    private Long lessonId;
    private LessonProgressStatus status;
    private Integer score;
    private Integer correctCount;
    private Integer totalCount;
    private Integer xpEarned;
    private OffsetDateTime startedAt;
    private OffsetDateTime completedAt;
}

