package com.grammaragent.lesson.repository;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.lesson.mapper.LessonMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MyBatisLessonCatalogRepository implements LessonCatalogRepository {

    private final LessonMapper lessonMapper;

    @Override
    public Optional<Lesson> findEnabledById(Long lessonId) {
        return Optional.ofNullable(lessonMapper.selectOne(Wrappers.<Lesson>lambdaQuery()
                .eq(Lesson::getId, lessonId)
                .eq(Lesson::getEnabled, true)));
    }

    @Override
    public List<Lesson> findEnabledByGrammarPointId(Long grammarPointId) {
        return lessonMapper.selectList(Wrappers.<Lesson>lambdaQuery()
                .eq(Lesson::getGrammarPointId, grammarPointId)
                .eq(Lesson::getEnabled, true)
                .orderByAsc(Lesson::getSortOrder, Lesson::getId));
    }

    @Override
    public List<Lesson> findEnabledByGrammarPointIds(Collection<Long> grammarPointIds) {
        if (grammarPointIds.isEmpty()) {
            return List.of();
        }
        return lessonMapper.selectList(Wrappers.<Lesson>lambdaQuery()
                .in(Lesson::getGrammarPointId, grammarPointIds)
                .eq(Lesson::getEnabled, true)
                .orderByAsc(Lesson::getGrammarPointId, Lesson::getSortOrder, Lesson::getId));
    }
}
