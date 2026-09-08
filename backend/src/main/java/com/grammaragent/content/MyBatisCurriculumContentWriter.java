package com.grammaragent.content;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.grammaragent.content.model.CurriculumContent;
import com.grammaragent.course.entity.Chapter;
import com.grammaragent.course.entity.Language;
import com.grammaragent.course.entity.LanguageLevel;
import com.grammaragent.course.mapper.ChapterMapper;
import com.grammaragent.course.mapper.LanguageLevelMapper;
import com.grammaragent.course.mapper.LanguageMapper;
import com.grammaragent.grammar.entity.GrammarPoint;
import com.grammaragent.grammar.entity.GrammarPointPrerequisite;
import com.grammaragent.grammar.mapper.GrammarPointMapper;
import com.grammaragent.grammar.mapper.GrammarPointPrerequisiteMapper;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.lesson.mapper.LessonMapper;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.mapper.QuestionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Repository
@RequiredArgsConstructor
public class MyBatisCurriculumContentWriter implements CurriculumContentWriter {

    private static final String LEGACY_BE_CODE = "EN_A1_BE_001";

    private final LanguageMapper languageMapper;
    private final LanguageLevelMapper levelMapper;
    private final ChapterMapper chapterMapper;
    private final GrammarPointMapper grammarPointMapper;
    private final GrammarPointPrerequisiteMapper prerequisiteMapper;
    private final LessonMapper lessonMapper;
    private final QuestionMapper questionMapper;

    @Override
    public ImportResult upsert(CurriculumContent content) {
        Language language = upsertLanguage(content);
        LanguageLevel level = upsertLevel(language.getId(), content);
        Map<String, Chapter> chapters = upsertChapters(level.getId(), content);
        Map<String, GrammarPoint> points = upsertGrammarPoints(level.getId(), chapters, content);
        int lessons = upsertLessonsAndQuestions(points, content);
        int questions = countEnabledQuestions(points.values().stream().map(GrammarPoint::getId).toList());
        int prerequisites = reconcilePrerequisites(points, content);
        disableOutOfSourceChapters(level.getId(), chapters.values().stream().map(Chapter::getId).collect(Collectors.toSet()));
        return new ImportResult(
                language.getId(), level.getId(), chapters.size(), points.size(), lessons, questions, prerequisites);
    }

    private Language upsertLanguage(CurriculumContent content) {
        Language language = languageMapper.selectOne(Wrappers.<Language>lambdaQuery()
                .eq(Language::getCode, content.languageCode()).last("LIMIT 1"));
        if (language == null) {
            language = new Language();
            language.setCode(content.languageCode());
        }
        language.setName(content.languageName());
        language.setNativeName(content.nativeName());
        language.setEnabled(true);
        language.setSortOrder(1);
        persist(languageMapper, language);
        return language;
    }

    private LanguageLevel upsertLevel(Long languageId, CurriculumContent content) {
        LanguageLevel level = levelMapper.selectOne(Wrappers.<LanguageLevel>lambdaQuery()
                .eq(LanguageLevel::getLanguageId, languageId)
                .eq(LanguageLevel::getCode, content.levelCode()).last("LIMIT 1"));
        if (level == null) {
            level = new LanguageLevel();
            level.setLanguageId(languageId);
            level.setCode(content.levelCode());
        }
        level.setName(content.levelName());
        level.setDescription(content.levelDescription());
        level.setSortOrder(1);
        persist(levelMapper, level);
        return level;
    }

    private Map<String, Chapter> upsertChapters(Long levelId, CurriculumContent content) {
        Map<Integer, Chapter> existingBySort = chapterMapper.selectList(Wrappers.<Chapter>lambdaQuery()
                        .eq(Chapter::getLanguageLevelId, levelId))
                .stream().collect(Collectors.toMap(Chapter::getSortOrder, Function.identity(), (left, right) -> left));
        Map<String, Chapter> result = new HashMap<>();
        for (var source : content.chapters()) {
            Chapter chapter = existingBySort.get(source.sortOrder());
            if (chapter == null) {
                chapter = new Chapter();
                chapter.setLanguageLevelId(levelId);
                chapter.setSortOrder(source.sortOrder());
            }
            chapter.setTitle(source.title());
            chapter.setDescription(source.description());
            chapter.setEnabled(true);
            persist(chapterMapper, chapter);
            result.put(source.key(), chapter);
        }
        return result;
    }

    private Map<String, GrammarPoint> upsertGrammarPoints(
            Long levelId,
            Map<String, Chapter> chapters,
            CurriculumContent content) {
        List<Long> allChapterIds = chapterMapper.selectList(Wrappers.<Chapter>lambdaQuery()
                        .eq(Chapter::getLanguageLevelId, levelId))
                .stream().map(Chapter::getId).toList();
        List<GrammarPoint> existing = allChapterIds.isEmpty() ? List.of()
                : grammarPointMapper.selectList(Wrappers.<GrammarPoint>lambdaQuery()
                        .in(GrammarPoint::getChapterId, allChapterIds));
        Map<String, GrammarPoint> existingByCode = existing.stream()
                .collect(Collectors.toMap(GrammarPoint::getCode, Function.identity(), (left, right) -> left));
        Map<String, GrammarPoint> result = new HashMap<>();

        for (var chapterSource : content.chapters()) {
            Chapter chapter = chapters.get(chapterSource.key());
            for (var source : chapterSource.grammarPoints()) {
                GrammarPoint point = existingByCode.get(source.code());
                if (point == null && "A1-003".equals(source.code())) {
                    point = existingByCode.get(LEGACY_BE_CODE);
                }
                if (point == null) {
                    point = new GrammarPoint();
                }
                point.setChapterId(chapter.getId());
                point.setCode(source.code());
                point.setTitle(source.title());
                point.setDescription(source.description());
                point.setGrammarRule(source.grammarRule());
                point.setExamples(source.examples());
                point.setCommonErrors(source.commonErrors());
                point.setDifficulty(source.difficulty());
                point.setSortOrder(source.sortOrder());
                point.setEnabled(true);
                persist(grammarPointMapper, point);
                result.put(source.code(), point);
            }
        }

        Set<Long> sourceIds = result.values().stream().map(GrammarPoint::getId).collect(Collectors.toSet());
        for (GrammarPoint point : existing) {
            if (!sourceIds.contains(point.getId()) && Boolean.TRUE.equals(point.getEnabled())) {
                point.setEnabled(false);
                grammarPointMapper.updateById(point);
            }
        }
        return result;
    }

    private int upsertLessonsAndQuestions(Map<String, GrammarPoint> points, CurriculumContent content) {
        int enabledLessonCount = 0;
        for (var chapter : content.chapters()) {
            for (var pointSource : chapter.grammarPoints()) {
                GrammarPoint point = points.get(pointSource.code());
                Map<Integer, Lesson> existingLessons = lessonMapper.selectList(Wrappers.<Lesson>lambdaQuery()
                                .eq(Lesson::getGrammarPointId, point.getId()))
                        .stream().collect(Collectors.toMap(Lesson::getSortOrder, Function.identity(), (left, right) -> left));
                Set<Long> sourceLessonIds = new HashSet<>();
                for (var lessonSource : pointSource.lessons()) {
                    Lesson lesson = existingLessons.get(lessonSource.sortOrder());
                    if (lesson == null) {
                        lesson = new Lesson();
                        lesson.setGrammarPointId(point.getId());
                        lesson.setSortOrder(lessonSource.sortOrder());
                    }
                    lesson.setTitle(lessonSource.title());
                    lesson.setDescription(lessonSource.description());
                    lesson.setLessonType(lessonSource.lessonType());
                    lesson.setXpReward(lessonSource.xpReward());
                    lesson.setEnabled(true);
                    persist(lessonMapper, lesson);
                    sourceLessonIds.add(lesson.getId());
                    enabledLessonCount++;
                    upsertQuestions(point, lesson, lessonSource.questions());
                }
                for (Lesson lesson : existingLessons.values()) {
                    if (!sourceLessonIds.contains(lesson.getId()) && Boolean.TRUE.equals(lesson.getEnabled())) {
                        lesson.setEnabled(false);
                        lessonMapper.updateById(lesson);
                    }
                }
            }
        }
        return enabledLessonCount;
    }

    private void upsertQuestions(
            GrammarPoint point,
            Lesson lesson,
            List<CurriculumContent.QuestionContent> sourceQuestions) {
        List<Question> existingQuestions = questionMapper.selectList(Wrappers.<Question>lambdaQuery()
                        .eq(Question::getLessonId, lesson.getId()))
                .stream().toList();
        Map<String, Question> existingByCode = existingQuestions.stream()
                .collect(Collectors.toMap(Question::getQuestionCode, Function.identity(), (left, right) -> left));
        Set<Long> sourceIds = new HashSet<>();
        for (var source : sourceQuestions) {
            Question question = existingByCode.get(source.questionCode());
            if (question == null) {
                question = new Question();
            }
            question.setQuestionCode(source.questionCode());
            question.setLessonId(lesson.getId());
            question.setSortOrder(source.sortOrder());
            question.setGrammarPointId(point.getId());
            question.setQuestionType(source.questionType());
            question.setQuestionContent(source.questionContent());
            question.setOptions(source.options() == null || source.options().isNull() ? null : source.options());
            question.setCorrectAnswer(source.correctAnswer());
            question.setExplanation(source.explanation());
            question.setDifficulty(source.difficulty());
            question.setEnabled(true);
            persist(questionMapper, question);
            sourceIds.add(question.getId());
        }
        for (Question question : existingQuestions) {
            if (!sourceIds.contains(question.getId()) && Boolean.TRUE.equals(question.getEnabled())) {
                question.setEnabled(false);
                questionMapper.updateById(question);
            }
        }
    }

    private int reconcilePrerequisites(Map<String, GrammarPoint> points, CurriculumContent content) {
        int count = 0;
        for (var chapter : content.chapters()) {
            for (var source : chapter.grammarPoints()) {
                GrammarPoint point = points.get(source.code());
                Map<Long, GrammarPointPrerequisite> existing = prerequisiteMapper.selectList(
                                Wrappers.<GrammarPointPrerequisite>lambdaQuery()
                                        .eq(GrammarPointPrerequisite::getGrammarPointId, point.getId()))
                        .stream().collect(Collectors.toMap(
                                GrammarPointPrerequisite::getPrerequisiteGrammarPointId,
                                Function.identity(), (left, right) -> left));
                Set<Long> sourceIds = new HashSet<>();
                for (String prerequisiteCode : source.prerequisiteCodes()) {
                    Long prerequisiteId = points.get(prerequisiteCode).getId();
                    sourceIds.add(prerequisiteId);
                    count++;
                    if (!existing.containsKey(prerequisiteId)) {
                        GrammarPointPrerequisite edge = new GrammarPointPrerequisite();
                        edge.setGrammarPointId(point.getId());
                        edge.setPrerequisiteGrammarPointId(prerequisiteId);
                        prerequisiteMapper.insert(edge);
                    }
                }
                for (var edge : existing.values()) {
                    if (!sourceIds.contains(edge.getPrerequisiteGrammarPointId())) {
                        prerequisiteMapper.deleteById(edge.getId());
                    }
                }
            }
        }
        return count;
    }

    private int countEnabledQuestions(List<Long> pointIds) {
        if (pointIds.isEmpty()) {
            return 0;
        }
        return Math.toIntExact(questionMapper.selectCount(Wrappers.<Question>lambdaQuery()
                .in(Question::getGrammarPointId, pointIds)
                .eq(Question::getEnabled, true)));
    }

    private void disableOutOfSourceChapters(Long levelId, Set<Long> sourceIds) {
        for (Chapter chapter : chapterMapper.selectList(Wrappers.<Chapter>lambdaQuery()
                .eq(Chapter::getLanguageLevelId, levelId))) {
            if (!sourceIds.contains(chapter.getId()) && Boolean.TRUE.equals(chapter.getEnabled())) {
                chapter.setEnabled(false);
                chapterMapper.updateById(chapter);
            }
        }
    }

    private <T> void persist(com.baomidou.mybatisplus.core.mapper.BaseMapper<T> mapper, T entity) {
        if (((com.grammaragent.common.persistence.BaseEntity) entity).getId() == null) {
            mapper.insert(entity);
        } else {
            mapper.updateById(entity);
        }
    }
}
