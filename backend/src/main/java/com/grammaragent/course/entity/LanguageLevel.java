package com.grammaragent.course.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.grammaragent.common.persistence.BaseEntity;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@TableName("language_levels")
public class LanguageLevel extends BaseEntity {

    private Long languageId;
    private String code;
    private String name;
    private String description;
    private Integer sortOrder;
}

