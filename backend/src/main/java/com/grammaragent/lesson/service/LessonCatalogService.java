package com.grammaragent.lesson.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.grammar.repository.GrammarCatalogRepository;
import com.grammaragent.lesson.dto.LessonDetailResponse;
import com.grammaragent.lesson.dto.LessonSummaryResponse;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.lesson.repository.LessonCatalogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Comparator;

@Service
@RequiredArgsConstructor
public class LessonCatalogService {

    private final GrammarCatalogRepository grammarRepository;
    private final LessonCatalogRepository lessonRepository;

    public List<LessonSummaryResponse> getLessons(Long grammarPointId) {
        grammarRepository.findEnabledById(grammarPointId)
                .orElseThrow(() -> new BusinessException(ErrorCode.GRAMMAR_POINT_NOT_FOUND));
        return lessonRepository.findEnabledByGrammarPointId(grammarPointId).stream()
                .filter(lesson -> Boolean.TRUE.equals(lesson.getEnabled()))
                .sorted(Comparator.comparing(Lesson::getSortOrder).thenComparing(Lesson::getId))
                .map(this::toSummary)
                .toList();
    }

    public LessonDetailResponse getLesson(Long lessonId) {
        Lesson lesson = lessonRepository.findEnabledById(lessonId)
                .orElseThrow(() -> new BusinessException(ErrorCode.LESSON_NOT_FOUND));
        return new LessonDetailResponse(
                lesson.getId(),
                lesson.getGrammarPointId(),
                lesson.getTitle(),
                lesson.getDescription(),
                lesson.getLessonType(),
                lesson.getXpReward(),
                lesson.getSortOrder());
    }

    private LessonSummaryResponse toSummary(Lesson lesson) {
        return new LessonSummaryResponse(
                lesson.getId(),
                lesson.getTitle(),
                lesson.getDescription(),
                lesson.getLessonType(),
                lesson.getXpReward(),
                lesson.getSortOrder());
    }
}
