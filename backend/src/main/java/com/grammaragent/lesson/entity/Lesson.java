package com.grammaragent.lesson.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.grammaragent.common.persistence.BaseEntity;
import com.grammaragent.lesson.enums.LessonType;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@TableName("lessons")
public class Lesson extends BaseEntity {

    private Long grammarPointId;
    private String title;
    private String description;
    private LessonType lessonType;
    private Integer xpReward;
    private Integer sortOrder;
    private Boolean enabled;
}

