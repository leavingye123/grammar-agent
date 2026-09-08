package com.grammaragent.dashboard.service;

import com.grammaragent.course.entity.Chapter;
import com.grammaragent.course.entity.Language;
import com.grammaragent.course.entity.LanguageLevel;
import com.grammaragent.course.service.LearningPathService;
import com.grammaragent.course.service.LearningPathService.LearningPathStructure;
import com.grammaragent.dashboard.dto.DashboardResponse;
import com.grammaragent.grammar.entity.GrammarPoint;
import com.grammaragent.learning.entity.LessonAttempt;
import com.grammaragent.learning.entity.UserLearningProgress;
import com.grammaragent.learning.entity.UserLessonProgress;
import com.grammaragent.learning.entity.UserStreak;
import com.grammaragent.learning.enums.LessonProgressStatus;
import com.grammaragent.learning.repository.LearningProgressRepository;
import com.grammaragent.learning.repository.LessonAttemptRepository;
import com.grammaragent.learning.repository.LessonProgressRepository;
import com.grammaragent.learning.repository.UserStreakRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.lesson.enums.LessonType;
import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.entity.WrongQuestion;
import com.grammaragent.question.repository.UserAnswerCounts;
import com.grammaragent.question.repository.UserAnswerRepository;
import com.grammaragent.question.repository.WrongQuestionRepository;
import com.grammaragent.question.repository.WrongQuestionSummary;
import com.grammaragent.user.entity.User;
import com.grammaragent.user.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.OffsetDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;

class DashboardServiceTest {

    @Test
    void shouldBuildDashboardForNewUserWithDefaults() {
        Fixtures fixtures = new Fixtures();
        fixtures.answerCounts.setTotal(10);
        fixtures.answerCounts.setCorrect(6);
        fixtures.wrongSummary.setDueCount(3);

        DashboardResponse response = fixtures.service.getDashboard(7L);

        assertEquals("tester", response.user().username());
        assertEquals("en", response.user().currentLanguage());
        assertEquals("A1", response.user().currentLevel());
        assertEquals(1001L, response.continueLearning().grammarPointId());
        assertEquals("be 动词基础", response.continueLearning().grammarPointTitle());
        assertEquals(10L, response.continueLearning().lessonId());
        assertEquals("Lesson 1", response.continueLearning().lessonTitle());
        assertEquals(30, response.today().goalXp());
        assertEquals(0, response.today().xpEarned());
        assertEquals(0, response.today().completedLessons());
        assertEquals(3, response.review().dueCount());
        assertEquals(0, response.progress().completedLessons());
        assertEquals(1, response.progress().totalLessons());
        assertEquals(0, response.progress().averageMastery());
        assertEquals(10, response.statistics().totalAnsweredQuestions());
        assertEquals(6, response.statistics().correctAnswers());
        assertEquals(60, response.statistics().accuracy());
        assertEquals(0, response.statistics().totalXp());
        assertEquals(0, response.streak().currentStreak());
        assertEquals(0, response.streak().maxStreak());
    }

    @Test
    void shouldPrioritizeInProgressLessonForContinueLearning() {
        Fixtures fixtures = new Fixtures();
        fixtures.lessonProgressRows = List.of(lessonProgress(10L, LessonProgressStatus.IN_PROGRESS));

        DashboardResponse response = fixtures.service.getDashboard(7L);

        assertNotNull(response.continueLearning());
        assertEquals(10L, response.continueLearning().lessonId());
        assertEquals("A1", response.user().currentLevel());
    }

    @Test
    void shouldReturnNullContinueLearningWhenAllLessonsCompleted() {
        Fixtures fixtures = new Fixtures();
        fixtures.lessonProgressRows = List.of(lessonProgress(10L, LessonProgressStatus.COMPLETED));

        DashboardResponse response = fixtures.service.getDashboard(7L);

        assertNull(response.continueLearning());
        assertEquals("A1", response.user().currentLevel());
        assertEquals(1, response.progress().completedLessons());
    }

    @Test
    void masteryShouldDefaultToZeroWithoutLearningProgressRecord() {
        Fixtures fixtures = new Fixtures();

        DashboardResponse response = fixtures.service.getDashboard(7L);

        assertEquals(0, response.progress().averageMastery());
    }

    private static UserLessonProgress lessonProgress(Long lessonId, LessonProgressStatus status) {
        UserLessonProgress progress = new UserLessonProgress();
        progress.setUserId(7L);
        progress.setLessonId(lessonId);
        progress.setStatus(status);
        progress.setUpdatedAt(OffsetDateTime.now());
        return progress;
    }

    private static final class Fixtures {

        private final UserAnswerCounts answerCounts = new UserAnswerCounts();
        private final WrongQuestionSummary wrongSummary = new WrongQuestionSummary();
        private List<UserLessonProgress> lessonProgressRows = List.of();

        private final DashboardService service;

        private Fixtures() {
            service = new DashboardService(
                    new FakeUserRepository(),
                    new FixedLearningPathService(),
                    new FakeLessonProgressRepository(),
                    new FakeLearningProgressRepository(),
                    new FakeLessonAttemptRepository(),
                    new FakeUserAnswerRepository(),
                    new FakeWrongQuestionRepository(),
                    new FakeUserStreakRepository());
            ReflectionTestUtils.setField(service, "defaultLanguageCode", "en");
            ReflectionTestUtils.setField(service, "dailyGoalXp", 30);
        }

        private final class FakeLessonProgressRepository implements LessonProgressRepository {

            @Override
            public void upsert(
                    Long userId, Long lessonId, LessonProgressStatus status, int score,
                    int correctCount, int totalCount, int xpEarned, OffsetDateTime now) {
            }

            @Override
            public Optional<UserLessonProgress> findByUserAndLesson(Long userId, Long lessonId) {
                return Optional.empty();
            }

            @Override
            public List<UserLessonProgress> findByUserId(Long userId) {
                return lessonProgressRows;
            }
        }

        private final class FakeUserAnswerRepository implements UserAnswerRepository {

            @Override
            public void insert(UserAnswer userAnswer) {
            }

            @Override
            public List<UserAnswer> findLatestByQuestionIdsInAttempt(
                    Long userId, Collection<Long> questionIds, Long attemptId) {
                return List.of();
            }

            @Override
            public UserAnswerCounts countByUser(Long userId) {
                return answerCounts;
            }
        }

        private final class FakeWrongQuestionRepository implements WrongQuestionRepository {

            @Override
            public void recordWrong(Long userId, Long questionId, OffsetDateTime wrongAt, OffsetDateTime nextReviewAt) {
            }

            @Override
            public List<WrongQuestion> findDueByUserId(Long userId, OffsetDateTime now, int limit) {
                return List.of();
            }

            @Override
            public List<WrongQuestion> findUnmasteredByUserId(Long userId, int offset, int limit) {
                return List.of();
            }

            @Override
            public WrongQuestionSummary summarize(Long userId, OffsetDateTime now) {
                return wrongSummary;
            }

            @Override
            public Optional<WrongQuestion> findForUpdate(Long userId, Long questionId) {
                return Optional.empty();
            }

            @Override
            public void updateReviewResult(WrongQuestion wrongQuestion, OffsetDateTime updatedAt) {
            }
        }
    }

    private static final class FakeUserRepository implements UserRepository {

        @Override
        public Optional<User> findByEmailIgnoreCase(String normalizedEmail) {
            return Optional.empty();
        }

        @Override
        public Optional<User> findById(Long userId) {
            User user = new User();
            user.setId(userId);
            user.setUsername("tester");
            return Optional.of(user);
        }

        @Override
        public User insert(User user) {
            return user;
        }

        @Override
        public void update(User user) {
        }
    }

    private static final class FixedLearningPathService extends LearningPathService {

        private FixedLearningPathService() {
            super(null, null, null, null);
        }

        @Override
        public LearningPathStructure assembleStructure(String languageCode) {
            Language language = new Language();
            language.setId(1L);
            language.setCode("en");
            language.setName("English");
            language.setNativeName("English");

            LanguageLevel level = new LanguageLevel();
            level.setId(11L);
            level.setLanguageId(1L);
            level.setCode("A1");
            level.setName("A1");
            level.setSortOrder(1);

            Chapter chapter = new Chapter();
            chapter.setId(101L);
            chapter.setLanguageLevelId(11L);
            chapter.setTitle("基础句子");
            chapter.setSortOrder(1);

            GrammarPoint grammarPoint = new GrammarPoint();
            grammarPoint.setId(1001L);
            grammarPoint.setChapterId(101L);
            grammarPoint.setTitle("be 动词基础");
            grammarPoint.setDifficulty(1);
            grammarPoint.setSortOrder(1);

            Lesson lesson = new Lesson();
            lesson.setId(10L);
            lesson.setGrammarPointId(1001L);
            lesson.setTitle("Lesson 1");
            lesson.setLessonType(LessonType.LEARNING);
            lesson.setXpReward(10);
            lesson.setSortOrder(1);

            return new LearningPathStructure(
                    language,
                    List.of(level),
                    Map.of(11L, List.of(chapter)),
                    Map.of(101L, List.of(grammarPoint)),
                    Map.of(1001L, List.of(lesson)),
                    Map.of(1001L, List.of()),
                    Map.of(10L, 2));
        }
    }

    private static final class FakeLearningProgressRepository implements LearningProgressRepository {

        @Override
        public UserLearningProgress incrementAndGet(
                Long userId, Long grammarPointId, boolean correct, OffsetDateTime studiedAt) {
            throw new UnsupportedOperationException();
        }

        @Override
        public List<UserLearningProgress> findByUserId(Long userId) {
            return List.of();
        }
    }

    private static final class FakeLessonAttemptRepository implements LessonAttemptRepository {

        @Override
        public LessonAttempt findOrCreateActive(Long userId, Long lessonId, OffsetDateTime now) {
            throw new UnsupportedOperationException();
        }

        @Override
        public Optional<LessonAttempt> findActiveForUpdate(Long userId, Long lessonId) {
            return Optional.empty();
        }

        @Override
        public void complete(
                Long attemptId, int totalCount, int correctCount, int score, int xpEarned, OffsetDateTime completedAt) {
        }

        @Override
        public List<LessonAttempt> findByUserAndLesson(Long userId, Long lessonId) {
            return List.of();
        }

        @Override
        public long countCompletedAfter(Long userId, OffsetDateTime since) {
            return 0;
        }

        @Override
        public long sumXpCompletedAfter(Long userId, OffsetDateTime since) {
            return 0;
        }

        @Override
        public long sumTotalCompletedXp(Long userId) {
            return 0;
        }
    }

    private static final class FakeUserStreakRepository implements UserStreakRepository {

        @Override
        public Optional<UserStreak> findByUserId(Long userId) {
            return Optional.empty();
        }
    }
}
