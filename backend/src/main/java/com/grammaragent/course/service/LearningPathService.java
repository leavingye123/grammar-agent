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
import com.grammaragent.grammar.entity.GrammarPointPrerequisite;
import com.grammaragent.grammar.repository.GrammarCatalogRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.lesson.repository.LessonCatalogRepository;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.lesson.enums.LessonContentStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LearningPathService {

    private final CourseCatalogRepository courseRepository;
    private final GrammarCatalogRepository grammarRepository;
    private final LessonCatalogRepository lessonRepository;
    private final QuestionRepository questionRepository;

    public LearningPathResponse getLearningPath(String languageCode) {
        LearningPathStructure structure = assembleStructure(languageCode);
        List<LearningPathLevelResponse> levelResponses = structure.levels().stream()
                .map(level -> toLevel(level, structure))
                .toList();
        return new LearningPathResponse(
                new LanguageResponse(
                        structure.language().getId(),
                        structure.language().getCode(),
                        structure.language().getName(),
                        structure.language().getNativeName()),
                levelResponses);
    }

    /**
     * Loads the enabled course tree once so user-state overlays can reuse the same
     * structure without repeating the catalog queries.
     */
    public LearningPathStructure assembleStructure(String languageCode) {
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
        List<GrammarPointPrerequisite> prerequisites = grammarRepository.findPrerequisitesByGrammarPointIds(
                grammarPoints.stream().map(GrammarPoint::getId).toList());
        Map<Long, Integer> questionCountsByLesson = questionRepository.findEnabledByLessonIds(
                        lessons.stream().map(Lesson::getId).toList()).stream()
                .collect(Collectors.groupingBy(Question::getLessonId, Collectors.summingInt(item -> 1)));

        Map<Long, List<Lesson>> lessonsByGrammarPoint = lessons.stream()
                .collect(Collectors.groupingBy(Lesson::getGrammarPointId));
        Map<Long, List<GrammarPoint>> grammarPointsByChapter = grammarPoints.stream()
                .collect(Collectors.groupingBy(GrammarPoint::getChapterId));
        Map<Long, List<Chapter>> chaptersByLevel = chapters.stream()
                .collect(Collectors.groupingBy(Chapter::getLanguageLevelId));
        Map<Long, String> codeByPointId = grammarPoints.stream()
                .collect(Collectors.toMap(GrammarPoint::getId, GrammarPoint::getCode));
        Map<Long, List<String>> prerequisiteCodesByGrammarPoint = prerequisites.stream()
                .filter(edge -> codeByPointId.containsKey(edge.getPrerequisiteGrammarPointId()))
                .collect(Collectors.groupingBy(
                        GrammarPointPrerequisite::getGrammarPointId,
                        Collectors.mapping(
                                edge -> codeByPointId.get(edge.getPrerequisiteGrammarPointId()),
                                Collectors.toList())));

        return new LearningPathStructure(
                language,
                levels,
                chaptersByLevel,
                grammarPointsByChapter,
                lessonsByGrammarPoint,
                prerequisiteCodesByGrammarPoint,
                questionCountsByLesson);
    }

    private LearningPathLevelResponse toLevel(
            LanguageLevel level,
            LearningPathStructure structure) {
        List<LearningPathChapterResponse> chapters = structure.chaptersByLevel()
                .getOrDefault(level.getId(), List.of()).stream()
                .map(chapter -> toChapter(chapter, structure))
                .toList();
        return new LearningPathLevelResponse(
                level.getId(), level.getCode(), level.getName(), level.getSortOrder(), chapters);
    }

    private LearningPathChapterResponse toChapter(
            Chapter chapter,
            LearningPathStructure structure) {
        List<LearningPathGrammarPointResponse> grammarPoints = structure.grammarPointsByChapter()
                .getOrDefault(chapter.getId(), List.of()).stream()
                .map(grammarPoint -> toGrammarPoint(grammarPoint, structure))
                .toList();
        return new LearningPathChapterResponse(
                chapter.getId(), chapter.getTitle(), chapter.getSortOrder(), grammarPoints);
    }

    private LearningPathGrammarPointResponse toGrammarPoint(
            GrammarPoint grammarPoint,
            LearningPathStructure structure) {
        List<LearningPathLessonResponse> lessons = structure.lessonsByGrammarPoint()
                .getOrDefault(grammarPoint.getId(), List.of()).stream()
                .map(lesson -> new LearningPathLessonResponse(
                        lesson.getId(),
                        lesson.getTitle(),
                        lesson.getLessonType(),
                        lesson.getXpReward(),
                        lesson.getSortOrder(),
                        structure.questionCountsByLesson().getOrDefault(lesson.getId(), 0),
                        contentStatus(structure.questionCountsByLesson().getOrDefault(lesson.getId(), 0)),
                        null))
                .toList();
        return new LearningPathGrammarPointResponse(
                grammarPoint.getId(),
                grammarPoint.getCode(),
                grammarPoint.getTitle(),
                grammarPoint.getDifficulty(),
                grammarPoint.getSortOrder(),
                structure.prerequisiteCodesByGrammarPoint().getOrDefault(grammarPoint.getId(), List.of()),
                lessons,
                null,
                null,
                null,
                null);
    }

    /**
     * Immutable snapshot of the enabled course tree for a language. Lists are sorted
     * by {@code sortOrder, id} and grouped by their parent key.
     */
    public record LearningPathStructure(
            Language language,
            List<LanguageLevel> levels,
            Map<Long, List<Chapter>> chaptersByLevel,
            Map<Long, List<GrammarPoint>> grammarPointsByChapter,
            Map<Long, List<Lesson>> lessonsByGrammarPoint,
            Map<Long, List<String>> prerequisiteCodesByGrammarPoint,
            Map<Long, Integer> questionCountsByLesson
    ) {
    }

    public static LessonContentStatus contentStatus(int questionCount) {
        return questionCount > 0 ? LessonContentStatus.READY : LessonContentStatus.COMING_SOON;
    }
}
