package com.grammaragent.course.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.course.dto.LanguageResponse;
import com.grammaragent.course.dto.LearningPathChapterResponse;
import com.grammaragent.course.dto.LearningPathGrammarPointResponse;
import com.grammaragent.course.dto.LearningPathLessonResponse;
import com.grammaragent.course.dto.LearningPathLevelResponse;
import com.grammaragent.course.dto.LearningPathResponse;
import com.grammaragent.course.entity.Chapter;
import com.grammaragent.course.entity.Language;
import com.grammaragent.course.entity.LanguageLevel;
import com.grammaragent.course.repository.CourseCatalogRepository;
import com.grammaragent.grammar.entity.GrammarPoint;
import com.grammaragent.grammar.repository.GrammarCatalogRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.lesson.repository.LessonCatalogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Comparator;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LearningPathService {

    private final CourseCatalogRepository courseRepository;
    private final GrammarCatalogRepository grammarRepository;
    private final LessonCatalogRepository lessonRepository;

    public LearningPathResponse getLearningPath(String languageCode) {
        Language language = courseRepository
                .findEnabledLanguageByCode(languageCode.trim().toLowerCase(Locale.ROOT))
                .orElseThrow(() -> new BusinessException(ErrorCode.LANGUAGE_NOT_FOUND));

        List<LanguageLevel> levels = courseRepository.findLevelsByLanguageId(language.getId()).stream()
                .sorted(Comparator.comparing(LanguageLevel::getSortOrder).thenComparing(LanguageLevel::getId))
                .toList();
        List<Chapter> chapters = courseRepository.findEnabledChaptersByLevelIds(
                        levels.stream().map(LanguageLevel::getId).toList()).stream()
                .filter(chapter -> Boolean.TRUE.equals(chapter.getEnabled()))
                .sorted(Comparator.comparing(Chapter::getSortOrder).thenComparing(Chapter::getId))
                .toList();
        List<GrammarPoint> grammarPoints = grammarRepository.findEnabledByChapterIds(
                        chapters.stream().map(Chapter::getId).toList()).stream()
                .filter(grammarPoint -> Boolean.TRUE.equals(grammarPoint.getEnabled()))
                .sorted(Comparator.comparing(GrammarPoint::getSortOrder).thenComparing(GrammarPoint::getId))
                .toList();
        List<Lesson> lessons = lessonRepository.findEnabledByGrammarPointIds(
                        grammarPoints.stream().map(GrammarPoint::getId).toList()).stream()
                .filter(lesson -> Boolean.TRUE.equals(lesson.getEnabled()))
                .sorted(Comparator.comparing(Lesson::getSortOrder).thenComparing(Lesson::getId))
                .toList();

        Map<Long, List<Lesson>> lessonsByGrammarPoint = lessons.stream()
                .collect(Collectors.groupingBy(Lesson::getGrammarPointId));
        Map<Long, List<GrammarPoint>> grammarPointsByChapter = grammarPoints.stream()
                .collect(Collectors.groupingBy(GrammarPoint::getChapterId));
        Map<Long, List<Chapter>> chaptersByLevel = chapters.stream()
                .collect(Collectors.groupingBy(Chapter::getLanguageLevelId));

        List<LearningPathLevelResponse> levelResponses = levels.stream()
                .map(level -> toLevel(level, chaptersByLevel, grammarPointsByChapter, lessonsByGrammarPoint))
                .toList();

        return new LearningPathResponse(
                new LanguageResponse(language.getId(), language.getCode(), language.getName(), language.getNativeName()),
                levelResponses);
    }

    private LearningPathLevelResponse toLevel(
            LanguageLevel level,
            Map<Long, List<Chapter>> chaptersByLevel,
            Map<Long, List<GrammarPoint>> grammarPointsByChapter,
            Map<Long, List<Lesson>> lessonsByGrammarPoint) {
        List<LearningPathChapterResponse> chapters = chaptersByLevel.getOrDefault(level.getId(), List.of()).stream()
                .map(chapter -> toChapter(chapter, grammarPointsByChapter, lessonsByGrammarPoint))
                .toList();
        return new LearningPathLevelResponse(
                level.getId(), level.getCode(), level.getName(), level.getSortOrder(), chapters);
    }

    private LearningPathChapterResponse toChapter(
            Chapter chapter,
            Map<Long, List<GrammarPoint>> grammarPointsByChapter,
            Map<Long, List<Lesson>> lessonsByGrammarPoint) {
        List<LearningPathGrammarPointResponse> grammarPoints = grammarPointsByChapter
                .getOrDefault(chapter.getId(), List.of()).stream()
                .map(grammarPoint -> toGrammarPoint(grammarPoint, lessonsByGrammarPoint))
                .toList();
        return new LearningPathChapterResponse(
                chapter.getId(), chapter.getTitle(), chapter.getSortOrder(), grammarPoints);
    }

    private LearningPathGrammarPointResponse toGrammarPoint(
            GrammarPoint grammarPoint,
            Map<Long, List<Lesson>> lessonsByGrammarPoint) {
        List<LearningPathLessonResponse> lessons = lessonsByGrammarPoint
                .getOrDefault(grammarPoint.getId(), List.of()).stream()
                .map(lesson -> new LearningPathLessonResponse(
                        lesson.getId(),
                        lesson.getTitle(),
                        lesson.getLessonType(),
                        lesson.getXpReward(),
                        lesson.getSortOrder()))
                .toList();
        return new LearningPathGrammarPointResponse(
                grammarPoint.getId(),
                grammarPoint.getCode(),
                grammarPoint.getTitle(),
                grammarPoint.getDifficulty(),
                grammarPoint.getSortOrder(),
                lessons);
    }
}
