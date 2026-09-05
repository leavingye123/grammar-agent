package com.grammaragent.course.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.grammaragent.common.persistence.BaseEntity;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@TableName("languages")
public class Language extends BaseEntity {

    private String code;
    private String name;
    private String nativeName;
    private Boolean enabled;
    private Integer sortOrder;
}

