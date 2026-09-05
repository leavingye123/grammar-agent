package com.grammaragent.course.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.grammaragent.common.persistence.BaseEntity;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@TableName("chapters")
public class Chapter extends BaseEntity {

    private Long languageLevelId;
    private String title;
    private String description;
    private Integer sortOrder;
    private Boolean enabled;
}
