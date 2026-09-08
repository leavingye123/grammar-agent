package com.grammaragent.course.service;

import com.grammaragent.course.dto.LanguageResponse;
import com.grammaragent.course.dto.LearningPathChapterResponse;
import com.grammaragent.course.dto.LearningPathGrammarPointResponse;
import com.grammaragent.course.dto.LearningPathLessonResponse;
import com.grammaragent.course.dto.LearningPathLevelResponse;
import com.grammaragent.course.dto.LearningPathResponse;
import com.grammaragent.course.entity.Chapter;
import com.grammaragent.course.entity.LanguageLevel;
import com.grammaragent.course.service.LearningPathService.LearningPathStructure;
import com.grammaragent.grammar.entity.GrammarPoint;
import com.grammaragent.learning.entity.UserLearningProgress;
import com.grammaragent.learning.entity.UserLessonProgress;
import com.grammaragent.learning.enums.LessonProgressStatus;
import com.grammaragent.learning.repository.LearningProgressRepository;
import com.grammaragent.learning.repository.LessonProgressRepository;
import com.grammaragent.lesson.entity.Lesson;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserLearningPathService {

    private static final String NOT_STARTED = "NOT_STARTED";
    private static final String IN_PROGRESS = "IN_PROGRESS";
    private static final String COMPLETED = "COMPLETED";

    private final LearningPathService learningPathService;
    private final LessonProgressRepository lessonProgressRepository;
    private final LearningProgressRepository learningProgressRepository;

    public LearningPathResponse getUserLearningPath(Long userId, String languageCode) {
        LearningPathStructure structure = learningPathService.assembleStructure(languageCode);

        Map<Long, UserLessonProgress> progressByLesson = lessonProgressRepository.findByUserId(userId).stream()
                .collect(Collectors.toMap(UserLessonProgress::getLessonId, Function.identity(), (a, b) -> a));
        Map<Long, UserLearningProgress> masteryByGrammarPoint = learningProgressRepository.findByUserId(userId).stream()
                .collect(Collectors.toMap(UserLearningProgress::getGrammarPointId, Function.identity(), (a, b) -> a));

        List<LearningPathLevelResponse> levels = structure.levels().stream()
                .map(level -> toLevel(level, structure, progressByLesson, masteryByGrammarPoint))
                .toList();

        return new LearningPathResponse(
                new LanguageResponse(
                        structure.language().getId(),
                        structure.language().getCode(),
                        structure.language().getName(),
                        structure.language().getNativeName()),
                levels);
    }

    private LearningPathLevelResponse toLevel(
            LanguageLevel level,
            LearningPathStructure structure,
            Map<Long, UserLessonProgress> progressByLesson,
            Map<Long, UserLearningProgress> masteryByGrammarPoint) {
        List<LearningPathChapterResponse> chapters = structure.chaptersByLevel()
                .getOrDefault(level.getId(), List.of()).stream()
                .map(chapter -> toChapter(chapter, structure, progressByLesson, masteryByGrammarPoint))
                .toList();
        return new LearningPathLevelResponse(
                level.getId(), level.getCode(), level.getName(), level.getSortOrder(), chapters);
    }

    private LearningPathChapterResponse toChapter(
            Chapter chapter,
            LearningPathStructure structure,
            Map<Long, UserLessonProgress> progressByLesson,
            Map<Long, UserLearningProgress> masteryByGrammarPoint) {
        List<LearningPathGrammarPointResponse> grammarPoints = structure.grammarPointsByChapter()
                .getOrDefault(chapter.getId(), List.of()).stream()
                .map(grammarPoint -> toGrammarPoint(grammarPoint, structure, progressByLesson, masteryByGrammarPoint))
                .toList();
        return new LearningPathChapterResponse(
                chapter.getId(), chapter.getTitle(), chapter.getSortOrder(), grammarPoints);
    }

    private LearningPathGrammarPointResponse toGrammarPoint(
            GrammarPoint grammarPoint,
            LearningPathStructure structure,
            Map<Long, UserLessonProgress> progressByLesson,
            Map<Long, UserLearningProgress> masteryByGrammarPoint) {
        List<Lesson> lessons = structure.lessonsByGrammarPoint()
                .getOrDefault(grammarPoint.getId(), List.of());
        List<LearningPathLessonResponse> lessonResponses = lessons.stream()
                .map(lesson -> toLesson(lesson, progressByLesson))
                .toList();

        int completedLessons = (int) lessonResponses.stream()
                .filter(lesson -> COMPLETED.equals(lesson.status()))
                .count();
        int totalLessons = lessons.size();
        boolean anyInProgress = lessonResponses.stream()
                .anyMatch(lesson -> IN_PROGRESS.equals(lesson.status()));
        UserLearningProgress mastery = masteryByGrammarPoint.get(grammarPoint.getId());
        int masteryScore = mastery == null ? 0 : mastery.getMasteryScore();
        boolean hasActivity = completedLessons > 0 || anyInProgress || mastery != null;

        String status = NOT_STARTED;
        if (totalLessons > 0 && completedLessons == totalLessons) {
            status = COMPLETED;
        } else if (hasActivity) {
            status = IN_PROGRESS;
        }

        return new LearningPathGrammarPointResponse(
                grammarPoint.getId(),
                grammarPoint.getCode(),
                grammarPoint.getTitle(),
                grammarPoint.getDifficulty(),
                grammarPoint.getSortOrder(),
                structure.prerequisiteCodesByGrammarPoint().getOrDefault(grammarPoint.getId(), List.of()),
                lessonResponses,
                masteryScore,
                completedLessons,
                totalLessons,
                status);
    }

    private LearningPathLessonResponse toLesson(
            Lesson lesson,
            Map<Long, UserLessonProgress> progressByLesson) {
        UserLessonProgress progress = progressByLesson.get(lesson.getId());
        String status = progress == null
                ? NOT_STARTED
                : progress.getStatus() == LessonProgressStatus.COMPLETED ? COMPLETED : IN_PROGRESS;
        return new LearningPathLessonResponse(
                lesson.getId(),
                lesson.getTitle(),
                lesson.getLessonType(),
                lesson.getXpReward(),
                lesson.getSortOrder(),
                status);
    }
}
