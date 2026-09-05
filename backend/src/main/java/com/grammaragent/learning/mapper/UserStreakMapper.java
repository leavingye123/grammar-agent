package com.grammaragent.learning.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.grammaragent.learning.entity.UserStreak;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserStreakMapper extends BaseMapper<UserStreak> {
}
