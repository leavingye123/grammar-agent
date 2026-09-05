package com.grammaragent.learning.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.grammaragent.common.persistence.BaseEntity;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@TableName("user_streaks")
public class UserStreak extends BaseEntity {

    private Long userId;
    private Integer currentStreak;
    private Integer maxStreak;
    private LocalDate lastLearningDate;
}
