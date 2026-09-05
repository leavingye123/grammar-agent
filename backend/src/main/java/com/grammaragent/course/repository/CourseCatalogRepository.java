package com.grammaragent.course.repository;

import com.grammaragent.course.entity.Chapter;
import com.grammaragent.course.entity.Language;
import com.grammaragent.course.entity.LanguageLevel;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface CourseCatalogRepository {

    List<Language> findEnabledLanguages();

    Optional<Language> findEnabledLanguageByCode(String normalizedCode);

    Optional<LanguageLevel> findLevelById(Long levelId);

    List<LanguageLevel> findLevelsByLanguageId(Long languageId);

    Optional<Chapter> findEnabledChapterById(Long chapterId);

    List<Chapter> findEnabledChaptersByLevelId(Long levelId);

    List<Chapter> findEnabledChaptersByLevelIds(Collection<Long> levelIds);
}
