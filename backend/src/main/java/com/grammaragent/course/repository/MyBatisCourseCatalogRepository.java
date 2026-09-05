package com.grammaragent.course.repository;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.grammaragent.course.entity.Chapter;
import com.grammaragent.course.entity.Language;
import com.grammaragent.course.entity.LanguageLevel;
import com.grammaragent.course.mapper.ChapterMapper;
import com.grammaragent.course.mapper.LanguageLevelMapper;
import com.grammaragent.course.mapper.LanguageMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MyBatisCourseCatalogRepository implements CourseCatalogRepository {

    private final LanguageMapper languageMapper;
    private final LanguageLevelMapper languageLevelMapper;
    private final ChapterMapper chapterMapper;

    @Override
    public List<Language> findEnabledLanguages() {
        return languageMapper.selectList(Wrappers.<Language>lambdaQuery()
                .eq(Language::getEnabled, true)
                .orderByAsc(Language::getSortOrder, Language::getId));
    }

    @Override
    public Optional<Language> findEnabledLanguageByCode(String normalizedCode) {
        Language language = languageMapper.selectOne(Wrappers.<Language>query()
                .apply("LOWER(code) = {0}", normalizedCode)
                .eq("enabled", true)
                .last("LIMIT 1"));
        return Optional.ofNullable(language);
    }

    @Override
    public Optional<LanguageLevel> findLevelById(Long levelId) {
        return Optional.ofNullable(languageLevelMapper.selectById(levelId));
    }

    @Override
    public List<LanguageLevel> findLevelsByLanguageId(Long languageId) {
        return languageLevelMapper.selectList(Wrappers.<LanguageLevel>lambdaQuery()
                .eq(LanguageLevel::getLanguageId, languageId)
                .orderByAsc(LanguageLevel::getSortOrder, LanguageLevel::getId));
    }

    @Override
    public Optional<Chapter> findEnabledChapterById(Long chapterId) {
        return Optional.ofNullable(chapterMapper.selectOne(Wrappers.<Chapter>lambdaQuery()
                .eq(Chapter::getId, chapterId)
                .eq(Chapter::getEnabled, true)));
    }

    @Override
    public List<Chapter> findEnabledChaptersByLevelId(Long levelId) {
        return chapterMapper.selectList(Wrappers.<Chapter>lambdaQuery()
                .eq(Chapter::getLanguageLevelId, levelId)
                .eq(Chapter::getEnabled, true)
                .orderByAsc(Chapter::getSortOrder, Chapter::getId));
    }

    @Override
    public List<Chapter> findEnabledChaptersByLevelIds(Collection<Long> levelIds) {
        if (levelIds.isEmpty()) {
            return List.of();
        }
        return chapterMapper.selectList(Wrappers.<Chapter>lambdaQuery()
                .in(Chapter::getLanguageLevelId, levelIds)
                .eq(Chapter::getEnabled, true)
                .orderByAsc(Chapter::getLanguageLevelId, Chapter::getSortOrder, Chapter::getId));
    }
}
