package com.grammaragent.question.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.grammar.repository.GrammarCatalogRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.lesson.repository.LessonCatalogRepository;
import com.grammaragent.question.entity.Question;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class QuestionContextService {

    private final LessonCatalogRepository lessonRepository;
    private final GrammarCatalogRepository grammarRepository;

    public Lesson requireEnabledLesson(Long lessonId) {
        Lesson lesson = lessonRepository.findEnabledById(lessonId)
                .orElseThrow(() -> new BusinessException(ErrorCode.LESSON_NOT_FOUND));
        grammarRepository.findEnabledById(lesson.getGrammarPointId())
                .orElseThrow(() -> new BusinessException(ErrorCode.GRAMMAR_POINT_NOT_FOUND));
        return lesson;
    }

    public void validateQuestion(Question question, Lesson lesson) {
        if (!question.getLessonId().equals(lesson.getId())
                || !question.getGrammarPointId().equals(lesson.getGrammarPointId())) {
            throw new BusinessException(ErrorCode.QUESTION_CONTEXT_INVALID);
        }
    }
}
