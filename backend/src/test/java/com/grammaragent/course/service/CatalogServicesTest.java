package com.grammaragent.course.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.content.CurriculumContentLoader;
import com.grammaragent.content.CurriculumKnowledgeService;
import com.grammaragent.course.dto.LearningPathResponse;
import com.grammaragent.course.entity.Chapter;
import com.grammaragent.course.entity.Language;
import com.grammaragent.course.entity.LanguageLevel;
import com.grammaragent.course.repository.CourseCatalogRepository;
import com.grammaragent.grammar.entity.GrammarPoint;
import com.grammaragent.grammar.entity.GrammarPointPrerequisite;
import com.grammaragent.grammar.repository.GrammarCatalogRepository;
import com.grammaragent.grammar.service.GrammarCatalogService;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.lesson.enums.LessonType;
import com.grammaragent.lesson.repository.LessonCatalogRepository;
import com.grammaragent.lesson.service.LessonCatalogService;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.repository.QuestionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import com.grammaragent.lesson.enums.LessonContentStatus;

class CatalogServicesTest {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private FakeCourseRepository courseRepository;
    private FakeGrammarRepository grammarRepository;
    private FakeLessonRepository lessonRepository;
    private FakeQuestionRepository questionRepository;
    private CourseCatalogService courseService;
    private GrammarCatalogService grammarService;
    private LessonCatalogService lessonService;
    private LearningPathService learningPathService;

    @BeforeEach
    void setUp() {
        courseRepository = new FakeCourseRepository();
        grammarRepository = new FakeGrammarRepository();
        lessonRepository = new FakeLessonRepository();
        questionRepository = new FakeQuestionRepository();
        courseService = new CourseCatalogService(courseRepository);
        grammarService = new GrammarCatalogService(
                courseRepository,
                grammarRepository,
                new CurriculumKnowledgeService(new CurriculumContentLoader(objectMapper), objectMapper));
        lessonService = new LessonCatalogService(grammarRepository, lessonRepository, questionRepository);
        learningPathService = new LearningPathService(
                courseRepository, grammarRepository, lessonRepository, questionRepository);
    }

    @Test
    void shouldQueryAndSortEveryCatalogLevelAndReturnPrerequisites() {
        assertEquals(List.of("en"), courseService.getLanguages().stream().map(item -> item.code()).toList());
        assertEquals(
                List.of("A1", "A2"),
                courseService.getLevels(" EN ").stream().map(item -> item.code()).toList());
        assertEquals(
                List.of("Chapter 1", "Chapter 2"),
                courseService.getChapters(10L).stream().map(item -> item.title()).toList());
        assertEquals(
                List.of("GP 1", "GP 2"),
                grammarService.getGrammarPoints(100L).stream().map(item -> item.title()).toList());

        var detail = grammarService.getGrammarPoint(1001L);
        assertEquals("GP 2", detail.title());
        assertEquals(List.of("GP_1"), detail.prerequisites().stream().map(item -> item.code()).toList());
        assertEquals(1, detail.examples().size());

        var lessonSummaries = lessonService.getLessons(1000L);
        assertEquals(List.of("Lesson 1", "Lesson 2"), lessonSummaries.stream().map(item -> item.title()).toList());
        assertEquals(LessonContentStatus.COMING_SOON, lessonSummaries.getFirst().contentStatus());
        assertEquals(0, lessonSummaries.getFirst().questionCount());
        assertEquals(1000L, lessonService.getLesson(2000L).grammarPointId());
    }

    @Test
    void shouldReturnDomainSpecificNotFoundErrors() {
        assertError(ErrorCode.LANGUAGE_NOT_FOUND, () -> courseService.getLevels("missing"));
        assertError(ErrorCode.LEVEL_NOT_FOUND, () -> courseService.getChapters(999L));
        assertError(ErrorCode.CHAPTER_NOT_FOUND, () -> grammarService.getGrammarPoints(999L));
        assertError(ErrorCode.GRAMMAR_POINT_NOT_FOUND, () -> grammarService.getGrammarPoint(999L));
        assertError(ErrorCode.GRAMMAR_POINT_NOT_FOUND, () -> lessonService.getLessons(999L));
        assertError(ErrorCode.LESSON_NOT_FOUND, () -> lessonService.getLesson(999L));
    }

    @Test
    void shouldBuildEnabledLearningPathWithSixFixedRepositoryCalls() throws Exception {
        LearningPathResponse response = learningPathService.getLearningPath("EN");

        assertEquals("en", response.language().code());
        assertEquals(List.of("A1", "A2"), response.levels().stream().map(item -> item.code()).toList());
        assertEquals(
                List.of("Chapter 1", "Chapter 2"),
                response.levels().getFirst().chapters().stream().map(item -> item.title()).toList());
        assertEquals(
                List.of("GP 1", "GP 2"),
                response.levels().getFirst().chapters().getFirst().grammarPoints().stream()
                        .map(item -> item.title()).toList());
        assertEquals(
                List.of("Lesson 1", "Lesson 2"),
                response.levels().getFirst().chapters().getFirst().grammarPoints().getFirst().lessons().stream()
                        .map(item -> item.title()).toList());
        assertEquals(
                List.of("GP_1"),
                response.levels().getFirst().chapters().getFirst().grammarPoints().get(1).prerequisiteCodes());

        assertEquals(1, courseRepository.languageLookupCount);
        assertEquals(1, courseRepository.levelBatchCount);
        assertEquals(1, courseRepository.chapterBatchCount);
        assertEquals(1, grammarRepository.grammarPointBatchCount);
        assertEquals(1, lessonRepository.lessonBatchCount);
        assertEquals(1, grammarRepository.prerequisiteBatchCount);
        assertEquals(1, questionRepository.questionBatchCount);

        String json = objectMapper.writeValueAsString(response);
        assertFalse(json.contains("Hidden"));
        assertFalse(json.contains("questions"));
        assertFalse(json.contains("correctAnswer"));
        assertFalse(json.contains("passwordHash"));
    }

    private void assertError(ErrorCode expected, Runnable operation) {
        BusinessException exception = assertThrows(BusinessException.class, operation::run);
        assertEquals(expected, exception.getErrorCode());
    }

    private final class FakeCourseRepository implements CourseCatalogRepository {
        private final Language english = language(1L, "en", "English", true, 1);
        private final Language hiddenLanguage = language(2L, "de", "Hidden language", false, 2);
        private final List<LanguageLevel> levels = List.of(
                level(11L, 1L, "A2", 2),
                level(10L, 1L, "A1", 1));
        private final List<Chapter> chapters = List.of(
                chapter(101L, 10L, "Chapter 2", true, 2),
                chapter(102L, 10L, "Hidden chapter", false, 3),
                chapter(100L, 10L, "Chapter 1", true, 1));
        private int languageLookupCount;
        private int levelBatchCount;
        private int chapterBatchCount;

        @Override
        public List<Language> findEnabledLanguages() {
            return List.of(hiddenLanguage, english);
        }

        @Override
        public Optional<Language> findEnabledLanguageByCode(String normalizedCode) {
            languageLookupCount++;
            return english.getCode().equals(normalizedCode) ? Optional.of(english) : Optional.empty();
        }

        @Override
        public Optional<LanguageLevel> findLevelById(Long levelId) {
            return levels.stream().filter(item -> item.getId().equals(levelId)).findFirst();
        }

        @Override
        public List<LanguageLevel> findLevelsByLanguageId(Long languageId) {
            levelBatchCount++;
            return levels.stream().filter(item -> item.getLanguageId().equals(languageId)).toList();
        }

        @Override
        public Optional<Chapter> findEnabledChapterById(Long chapterId) {
            return chapters.stream()
                    .filter(item -> item.getId().equals(chapterId) && Boolean.TRUE.equals(item.getEnabled()))
                    .findFirst();
        }

        @Override
        public List<Chapter> findEnabledChaptersByLevelId(Long levelId) {
            return chapters.stream().filter(item -> item.getLanguageLevelId().equals(levelId)).toList();
        }

        @Override
        public List<Chapter> findEnabledChaptersByLevelIds(Collection<Long> levelIds) {
            chapterBatchCount++;
            return chapters.stream().filter(item -> levelIds.contains(item.getLanguageLevelId())).toList();
        }
    }

    private final class FakeGrammarRepository implements GrammarCatalogRepository {
        private final List<GrammarPoint> grammarPoints = List.of(
                grammarPoint(1001L, 100L, "GP_2", "GP 2", true, 2),
                grammarPoint(1002L, 100L, "HIDDEN", "Hidden grammar", false, 3),
                grammarPoint(1000L, 100L, "GP_1", "GP 1", true, 1));
        private int grammarPointBatchCount;
        private int prerequisiteBatchCount;

        @Override
        public Optional<GrammarPoint> findEnabledById(Long grammarPointId) {
            return grammarPoints.stream()
                    .filter(item -> item.getId().equals(grammarPointId) && Boolean.TRUE.equals(item.getEnabled()))
                    .findFirst();
        }

        @Override
        public List<GrammarPoint> findEnabledByChapterId(Long chapterId) {
            return grammarPoints.stream().filter(item -> item.getChapterId().equals(chapterId)).toList();
        }

        @Override
        public List<GrammarPoint> findEnabledByChapterIds(Collection<Long> chapterIds) {
            grammarPointBatchCount++;
            return grammarPoints.stream().filter(item -> chapterIds.contains(item.getChapterId())).toList();
        }

        @Override
        public List<GrammarPoint> findEnabledPrerequisites(Long grammarPointId) {
            return grammarPointId.equals(1001L) ? List.of(grammarPoints.get(2)) : List.of();
        }

        @Override
        public List<GrammarPointPrerequisite> findPrerequisitesByGrammarPointIds(Collection<Long> grammarPointIds) {
            prerequisiteBatchCount++;
            GrammarPointPrerequisite edge = new GrammarPointPrerequisite();
            edge.setGrammarPointId(1001L);
            edge.setPrerequisiteGrammarPointId(1000L);
            return List.of(edge);
        }
    }

    private final class FakeLessonRepository implements LessonCatalogRepository {
        private final List<Lesson> lessons = List.of(
                lesson(2001L, 1000L, "Lesson 2", true, 2),
                lesson(2002L, 1000L, "Hidden lesson", false, 3),
                lesson(2000L, 1000L, "Lesson 1", true, 1),
                lesson(2003L, 1001L, "GP 2 Lesson", true, 1));
        private int lessonBatchCount;

        @Override
        public Optional<Lesson> findEnabledById(Long lessonId) {
            return lessons.stream()
                    .filter(item -> item.getId().equals(lessonId) && Boolean.TRUE.equals(item.getEnabled()))
                    .findFirst();
        }

        @Override
        public List<Lesson> findEnabledByGrammarPointId(Long grammarPointId) {
            return lessons.stream().filter(item -> item.getGrammarPointId().equals(grammarPointId)).toList();
        }

        @Override
        public List<Lesson> findEnabledByGrammarPointIds(Collection<Long> grammarPointIds) {
            lessonBatchCount++;
            return lessons.stream().filter(item -> grammarPointIds.contains(item.getGrammarPointId())).toList();
        }
    }

    private final class FakeQuestionRepository implements QuestionRepository {
        private int questionBatchCount;

        @Override
        public Optional<Question> findEnabledById(Long questionId) {
            return Optional.empty();
        }

        @Override
        public List<Question> findEnabledByIds(Collection<Long> questionIds) {
            return List.of();
        }

        @Override
        public List<Question> findEnabledByLessonId(Long lessonId) {
            return List.of();
        }

        @Override
        public List<Question> findEnabledByLessonIds(Collection<Long> lessonIds) {
            questionBatchCount++;
            return List.of();
        }
    }

    private Language language(Long id, String code, String name, boolean enabled, int sortOrder) {
        Language language = new Language();
        language.setId(id);
        language.setCode(code);
        language.setName(name);
        language.setNativeName(name);
        language.setEnabled(enabled);
        language.setSortOrder(sortOrder);
        return language;
    }

    private LanguageLevel level(Long id, Long languageId, String code, int sortOrder) {
        LanguageLevel level = new LanguageLevel();
        level.setId(id);
        level.setLanguageId(languageId);
        level.setCode(code);
        level.setName(code);
        level.setDescription(code + " description");
        level.setSortOrder(sortOrder);
        return level;
    }

    private Chapter chapter(Long id, Long levelId, String title, boolean enabled, int sortOrder) {
        Chapter chapter = new Chapter();
        chapter.setId(id);
        chapter.setLanguageLevelId(levelId);
        chapter.setTitle(title);
        chapter.setDescription(title + " description");
        chapter.setEnabled(enabled);
        chapter.setSortOrder(sortOrder);
        return chapter;
    }

    private GrammarPoint grammarPoint(
            Long id, Long chapterId, String code, String title, boolean enabled, int sortOrder) {
        GrammarPoint grammarPoint = new GrammarPoint();
        grammarPoint.setId(id);
        grammarPoint.setChapterId(chapterId);
        grammarPoint.setCode(code);
        grammarPoint.setTitle(title);
        grammarPoint.setDescription(title + " description");
        grammarPoint.setGrammarRule(title + " rule");
        ArrayNode examples = objectMapper.createArrayNode().add(title + " example");
        grammarPoint.setExamples(examples);
        grammarPoint.setCommonErrors(objectMapper.createArrayNode());
        grammarPoint.setDifficulty(1);
        grammarPoint.setEnabled(enabled);
        grammarPoint.setSortOrder(sortOrder);
        return grammarPoint;
    }

    private Lesson lesson(Long id, Long grammarPointId, String title, boolean enabled, int sortOrder) {
        Lesson lesson = new Lesson();
        lesson.setId(id);
        lesson.setGrammarPointId(grammarPointId);
        lesson.setTitle(title);
        lesson.setDescription(title + " description");
        lesson.setLessonType(LessonType.LEARNING);
        lesson.setXpReward(10);
        lesson.setEnabled(enabled);
        lesson.setSortOrder(sortOrder);
        return lesson;
    }
}
