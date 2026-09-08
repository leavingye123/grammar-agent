package com.grammaragent.course.service;

import com.grammaragent.course.dto.LearningPathGrammarPointResponse;
import com.grammaragent.course.dto.LearningPathLessonResponse;
import com.grammaragent.course.dto.LearningPathResponse;
import com.grammaragent.course.entity.Chapter;
import com.grammaragent.course.entity.Language;
import com.grammaragent.course.entity.LanguageLevel;
import com.grammaragent.course.service.LearningPathService.LearningPathStructure;
import com.grammaragent.grammar.entity.GrammarPoint;
import com.grammaragent.learning.entity.UserLearningProgress;
import com.grammaragent.learning.entity.UserLessonProgress;
import com.grammaragent.learning.enums.LessonProgressStatus;
import com.grammaragent.learning.repository.LearningProgressRepository;
import com.grammaragent.learning.repository.LessonProgressRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.lesson.enums.LessonType;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;

class UserLearningPathServiceTest {

    @Test
    void shouldReturnNotStartedAndZeroMasteryForNewUser() {
        Service service = service(List.of(), List.of());

        LearningPathResponse response = service.getUserLearningPath(7L, "en");

        LearningPathGrammarPointResponse gp = grammarPoint(response);
        LearningPathLessonResponse lesson = gp.lessons().getFirst();
        assertEquals(0, gp.masteryScore());
        assertEquals("NOT_STARTED", gp.status());
        assertEquals(0, gp.completedLessons());
        assertEquals(1, gp.totalLessons());
        assertEquals("NOT_STARTED", lesson.status());
    }

    @Test
    void shouldReflectCompletedLessonAndMastery() {
        UserLessonProgress progress = lessonProgress(LessonProgressStatus.COMPLETED);
        UserLearningProgress mastery = new UserLearningProgress();
        mastery.setUserId(7L);
        mastery.setGrammarPointId(1001L);
        mastery.setMasteryScore(72);
        Service service = service(List.of(progress), List.of(mastery));

        LearningPathResponse response = service.getUserLearningPath(7L, "en");

        LearningPathGrammarPointResponse gp = grammarPoint(response);
        assertEquals(72, gp.masteryScore());
        assertEquals("COMPLETED", gp.status());
        assertEquals(1, gp.completedLessons());
        assertEquals(1, gp.totalLessons());
        assertEquals("COMPLETED", gp.lessons().getFirst().status());
    }

    @Test
    void shouldMarkGrammarPointInProgressForPartialLesson() {
        UserLessonProgress progress = lessonProgress(LessonProgressStatus.IN_PROGRESS);
        Service service = service(List.of(progress), List.of());

        LearningPathResponse response = service.getUserLearningPath(7L, "en");

        LearningPathGrammarPointResponse gp = grammarPoint(response);
        assertEquals(0, gp.masteryScore());
        assertEquals("IN_PROGRESS", gp.status());
        assertEquals(0, gp.completedLessons());
        assertEquals("IN_PROGRESS", gp.lessons().getFirst().status());
    }

    private LearningPathGrammarPointResponse grammarPoint(LearningPathResponse response) {
        return response.levels().getFirst().chapters().getFirst().grammarPoints().getFirst();
    }

    private UserLessonProgress lessonProgress(LessonProgressStatus status) {
        UserLessonProgress progress = new UserLessonProgress();
        progress.setUserId(7L);
        progress.setLessonId(10L);
        progress.setStatus(status);
        return progress;
    }

    private Service service(List<UserLessonProgress> lessonProgress, List<UserLearningProgress> mastery) {
        return new Service(new FixedLearningPathService(), lessonProgress, mastery);
    }

    private record Service(
            LearningPathService learningPathService,
            List<UserLessonProgress> lessonProgress,
            List<UserLearningProgress> mastery
    ) {
        private LearningPathResponse getUserLearningPath(Long userId, String languageCode) {
            UserLearningPathService service = new UserLearningPathService(
                    learningPathService,
                    new FixedLessonProgressRepository(lessonProgress),
                    new FixedLearningProgressRepository(mastery));
            return service.getUserLearningPath(userId, languageCode);
        }
    }

    private static final class FixedLessonProgressRepository implements LessonProgressRepository {

        private final List<UserLessonProgress> rows;

        private FixedLessonProgressRepository(List<UserLessonProgress> rows) {
            this.rows = rows;
        }

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
            return rows;
        }
    }

    private static final class FixedLearningProgressRepository implements LearningProgressRepository {

        private final List<UserLearningProgress> rows;

        private FixedLearningProgressRepository(List<UserLearningProgress> rows) {
            this.rows = rows;
        }

        @Override
        public UserLearningProgress incrementAndGet(
                Long userId, Long grammarPointId, boolean correct, OffsetDateTime studiedAt) {
            throw new UnsupportedOperationException();
        }

        @Override
        public List<UserLearningProgress> findByUserId(Long userId) {
            return rows;
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
            grammarPoint.setCode("EN_A1_BE_001");
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
}
