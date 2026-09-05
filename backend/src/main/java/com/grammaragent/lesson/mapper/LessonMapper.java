package com.grammaragent.lesson.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.grammaragent.lesson.entity.Lesson;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface LessonMapper extends BaseMapper<Lesson> {
}
