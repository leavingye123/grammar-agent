package com.grammaragent.dashboard.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.course.entity.Chapter;
import com.grammaragent.course.entity.LanguageLevel;
import com.grammaragent.course.service.LearningPathService;
import com.grammaragent.course.service.LearningPathService.LearningPathStructure;
import com.grammaragent.dashboard.dto.DashboardResponse;
import com.grammaragent.grammar.entity.GrammarPoint;
import com.grammaragent.learning.entity.UserLearningProgress;
import com.grammaragent.learning.entity.UserLessonProgress;
import com.grammaragent.learning.entity.UserStreak;
import com.grammaragent.learning.enums.LessonProgressStatus;
import com.grammaragent.learning.repository.LearningProgressRepository;
import com.grammaragent.learning.repository.LessonAttemptRepository;
import com.grammaragent.learning.repository.LessonProgressRepository;
import com.grammaragent.learning.repository.UserStreakRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.question.repository.UserAnswerCounts;
import com.grammaragent.question.repository.UserAnswerRepository;
import com.grammaragent.question.repository.WrongQuestionRepository;
import com.grammaragent.user.entity.User;
import com.grammaragent.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final UserRepository userRepository;
    private final LearningPathService learningPathService;
    private final LessonProgressRepository lessonProgressRepository;
    private final LearningProgressRepository learningProgressRepository;
    private final LessonAttemptRepository lessonAttemptRepository;
    private final UserAnswerRepository userAnswerRepository;
    private final WrongQuestionRepository wrongQuestionRepository;
    private final UserStreakRepository userStreakRepository;

    @Value("${app.learning.default-language-code:en}")
    private String defaultLanguageCode;

    @Value("${app.learning.daily-goal-xp:30}")
    private int dailyGoalXp;

    @Transactional(readOnly = true)
    public DashboardResponse getDashboard(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        LearningPathStructure structure = learningPathService.assembleStructure(defaultLanguageCode);
        PathIndex index = new PathIndex(structure);

        List<UserLessonProgress> lessonProgress = lessonProgressRepository.findByUserId(userId);
        Map<Long, UserLessonProgress> progressByLesson = lessonProgress.stream()
                .collect(Collectors.toMap(UserLessonProgress::getLessonId, Function.identity(), (a, b) -> a));
        Set<Long> completedLessonIds = lessonProgress.stream()
                .filter(progress -> progress.getStatus() == LessonProgressStatus.COMPLETED)
                .map(UserLessonProgress::getLessonId)
                .collect(Collectors.toSet());

        Optional<UserLessonProgress> inProgress = lessonProgress.stream()
                .filter(progress -> progress.getStatus() == LessonProgressStatus.IN_PROGRESS)
                .max((a, b) -> compareNullable(a.getUpdatedAt(), b.getUpdatedAt()));

        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        OffsetDateTime dayStart = now.toLocalDate().atStartOfDay(ZoneOffset.UTC).toOffsetDateTime();

        DashboardResponse.ContinueLearning continueLearning = resolveContinueLearning(
                inProgress, completedLessonIds, index);
        int completedLessons = (int) index.orderedLessons().stream()
                .filter(lesson -> completedLessonIds.contains(lesson.getId()))
                .count();
        int averageMastery = averageMastery(userId, index);

        UserAnswerCounts answerCounts = userAnswerRepository.countByUser(userId);
        int accuracy = answerCounts.getTotal() == 0
                ? 0
                : Math.toIntExact(Math.round(answerCounts.getCorrect() * 100.0 / answerCounts.getTotal()));

        UserStreak streak = userStreakRepository.findByUserId(userId).orElse(null);

        return new DashboardResponse(
                new DashboardResponse.User(user.getUsername(), defaultLanguageCode, resolveCurrentLevel(index, completedLessonIds)),
                continueLearning,
                new DashboardResponse.Today(
                        (int) lessonAttemptRepository.countCompletedAfter(userId, dayStart),
                        (int) lessonAttemptRepository.sumXpCompletedAfter(userId, dayStart),
                        dailyGoalXp),
                new DashboardResponse.Review(wrongQuestionRepository.summarize(userId, now).getDueCount()),
                new DashboardResponse.Progress(completedLessons, index.totalLessons(), averageMastery),
                new DashboardResponse.Statistics(
                        answerCounts.getTotal(),
                        answerCounts.getCorrect(),
                        accuracy,
                        lessonAttemptRepository.sumTotalCompletedXp(userId)),
                new DashboardResponse.Streak(
                        streak == null ? 0 : streak.getCurrentStreak(),
                        streak == null ? 0 : streak.getMaxStreak()));
    }

    private DashboardResponse.ContinueLearning resolveContinueLearning(
            Optional<UserLessonProgress> inProgress,
            Set<Long> completedLessonIds,
            PathIndex index) {
        if (inProgress.isPresent()) {
            return toContinueLearning(inProgress.get().getLessonId(), index);
        }
        for (Lesson lesson : index.orderedLessons()) {
            if (!completedLessonIds.contains(lesson.getId())) {
                return toContinueLearning(lesson.getId(), index);
            }
        }
        return null;
    }

    private DashboardResponse.ContinueLearning toContinueLearning(Long lessonId, PathIndex index) {
        Lesson lesson = index.lessonById().get(lessonId);
        if (lesson == null) {
            return null;
        }
        GrammarPoint grammarPoint = index.grammarPointByLessonId().get(lessonId);
        return new DashboardResponse.ContinueLearning(
                grammarPoint == null ? null : grammarPoint.getId(),
                grammarPoint == null ? null : grammarPoint.getTitle(),
                lesson.getId(),
                lesson.getTitle());
    }

    private int averageMastery(Long userId, PathIndex index) {
        Map<Long, Integer> masteryByGrammarPoint = learningProgressRepository.findByUserId(userId).stream()
                .collect(Collectors.toMap(
                        UserLearningProgress::getGrammarPointId,
                        UserLearningProgress::getMasteryScore,
                        (a, b) -> a));
        List<Integer> scores = index.grammarPointIds().stream()
                .filter(masteryByGrammarPoint::containsKey)
                .map(masteryByGrammarPoint::get)
                .toList();
        if (scores.isEmpty()) {
            return 0;
        }
        double sum = scores.stream().mapToInt(Integer::intValue).sum();
        return (int) Math.round(sum / scores.size());
    }

    private String resolveCurrentLevel(PathIndex index, Set<Long> completedLessonIds) {
        for (LanguageLevel level : index.levels()) {
            List<Lesson> lessons = index.lessonsByLevel().getOrDefault(level.getId(), List.of());
            if (lessons.isEmpty()) {
                continue;
            }
            boolean allCompleted = lessons.stream().allMatch(lesson -> completedLessonIds.contains(lesson.getId()));
            if (!allCompleted) {
                return level.getCode();
            }
        }
        if (!index.levels().isEmpty()) {
            return index.levels().get(index.levels().size() - 1).getCode();
        }
        return null;
    }

    private static int compareNullable(OffsetDateTime a, OffsetDateTime b) {
        if (a == null && b == null) {
            return 0;
        }
        if (a == null) {
            return -1;
        }
        if (b == null) {
            return 1;
        }
        return a.compareTo(b);
    }

    private static final class PathIndex {

        private final List<LanguageLevel> levels;
        private final List<Lesson> orderedLessons = new ArrayList<>();
        private final Map<Long, Lesson> lessonById = new HashMap<>();
        private final Map<Long, GrammarPoint> grammarPointByLessonId = new HashMap<>();
        private final Map<Long, List<Lesson>> lessonsByLevel = new HashMap<>();
        private final Set<Long> grammarPointIds;
        private final int totalLessons;

        private PathIndex(LearningPathStructure structure) {
            this.levels = structure.levels();
            for (LanguageLevel level : structure.levels()) {
                List<Lesson> levelLessons = new ArrayList<>();
                for (Chapter chapter : structure.chaptersByLevel().getOrDefault(level.getId(), List.of())) {
                    for (GrammarPoint grammarPoint : structure.grammarPointsByChapter()
                            .getOrDefault(chapter.getId(), List.of())) {
                        List<Lesson> lessons = structure.lessonsByGrammarPoint()
                                .getOrDefault(grammarPoint.getId(), List.of());
                        levelLessons.addAll(lessons);
                        for (Lesson lesson : lessons) {
                            grammarPointByLessonId.put(lesson.getId(), grammarPoint);
                        }
                    }
                }
                lessonsByLevel.put(level.getId(), levelLessons);
                orderedLessons.addAll(levelLessons);
            }
            lessonById.putAll(orderedLessons.stream()
                    .collect(Collectors.toMap(Lesson::getId, Function.identity())));
            grammarPointIds = grammarPointByLessonId.values().stream()
                    .map(GrammarPoint::getId)
                    .collect(Collectors.toSet());
            totalLessons = orderedLessons.size();
        }

        private List<LanguageLevel> levels() {
            return levels;
        }

        private List<Lesson> orderedLessons() {
            return orderedLessons;
        }

        private Map<Long, Lesson> lessonById() {
            return lessonById;
        }

        private Map<Long, GrammarPoint> grammarPointByLessonId() {
            return grammarPointByLessonId;
        }

        private Map<Long, List<Lesson>> lessonsByLevel() {
            return lessonsByLevel;
        }

        private Set<Long> grammarPointIds() {
            return grammarPointIds;
        }

        private int totalLessons() {
            return totalLessons;
        }
    }
}
