package com.grammaragent.question.repository;

import com.grammaragent.question.entity.Question;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface QuestionRepository {

    Optional<Question> findEnabledById(Long questionId);

    List<Question> findEnabledByIds(Collection<Long> questionIds);

    List<Question> findEnabledByLessonId(Long lessonId);
}
