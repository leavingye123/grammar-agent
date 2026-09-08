package com.grammaragent.lesson.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.grammar.repository.GrammarCatalogRepository;
import com.grammaragent.lesson.dto.LessonDetailResponse;
import com.grammaragent.lesson.dto.LessonSummaryResponse;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.lesson.repository.LessonCatalogRepository;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.lesson.enums.LessonContentStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Comparator;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LessonCatalogService {

    private final GrammarCatalogRepository grammarRepository;
    private final LessonCatalogRepository lessonRepository;
    private final QuestionRepository questionRepository;

    public List<LessonSummaryResponse> getLessons(Long grammarPointId) {
        grammarRepository.findEnabledById(grammarPointId)
                .orElseThrow(() -> new BusinessException(ErrorCode.GRAMMAR_POINT_NOT_FOUND));
        List<Lesson> lessons = lessonRepository.findEnabledByGrammarPointId(grammarPointId).stream()
                .filter(lesson -> Boolean.TRUE.equals(lesson.getEnabled()))
                .sorted(Comparator.comparing(Lesson::getSortOrder).thenComparing(Lesson::getId))
                .toList();
        Map<Long, Integer> questionCounts = questionRepository.findEnabledByLessonIds(
                        lessons.stream().map(Lesson::getId).toList()).stream()
                .collect(Collectors.groupingBy(Question::getLessonId, Collectors.summingInt(item -> 1)));
        return lessons.stream().map(lesson -> toSummary(
                lesson, questionCounts.getOrDefault(lesson.getId(), 0))).toList();
    }

    public LessonDetailResponse getLesson(Long lessonId) {
        Lesson lesson = lessonRepository.findEnabledById(lessonId)
                .orElseThrow(() -> new BusinessException(ErrorCode.LESSON_NOT_FOUND));
        int questionCount = questionRepository.findEnabledByLessonId(lessonId).size();
        return new LessonDetailResponse(
                lesson.getId(),
                lesson.getGrammarPointId(),
                lesson.getTitle(),
                lesson.getDescription(),
                lesson.getLessonType(),
                lesson.getXpReward(),
                lesson.getSortOrder(),
                questionCount,
                contentStatus(questionCount));
    }

    private LessonSummaryResponse toSummary(Lesson lesson, int questionCount) {
        return new LessonSummaryResponse(
                lesson.getId(),
                lesson.getTitle(),
                lesson.getDescription(),
                lesson.getLessonType(),
                lesson.getXpReward(),
                lesson.getSortOrder(),
                questionCount,
                contentStatus(questionCount));
    }

    private LessonContentStatus contentStatus(int questionCount) {
        return questionCount > 0 ? LessonContentStatus.READY : LessonContentStatus.COMING_SOON;
    }
}
