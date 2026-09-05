package com.grammaragent.lesson.repository;

import com.grammaragent.lesson.entity.Lesson;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface LessonCatalogRepository {

    Optional<Lesson> findEnabledById(Long lessonId);

    List<Lesson> findEnabledByGrammarPointId(Long grammarPointId);

    List<Lesson> findEnabledByGrammarPointIds(Collection<Long> grammarPointIds);
}
