package com.grammaragent.course.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.course.dto.ChapterResponse;
import com.grammaragent.course.dto.LanguageLevelResponse;
import com.grammaragent.course.dto.LanguageResponse;
import com.grammaragent.course.entity.Chapter;
import com.grammaragent.course.entity.Language;
import com.grammaragent.course.entity.LanguageLevel;
import com.grammaragent.course.repository.CourseCatalogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;
import java.util.Comparator;

@Service
@RequiredArgsConstructor
public class CourseCatalogService {

    private final CourseCatalogRepository repository;

    public List<LanguageResponse> getLanguages() {
        return repository.findEnabledLanguages().stream()
                .filter(language -> Boolean.TRUE.equals(language.getEnabled()))
                .sorted(Comparator.comparing(Language::getSortOrder).thenComparing(Language::getId))
                .map(this::toLanguageResponse)
                .toList();
    }

    public List<LanguageLevelResponse> getLevels(String languageCode) {
        Language language = repository.findEnabledLanguageByCode(normalizeLanguageCode(languageCode))
                .orElseThrow(() -> new BusinessException(ErrorCode.LANGUAGE_NOT_FOUND));
        return repository.findLevelsByLanguageId(language.getId()).stream()
                .sorted(Comparator.comparing(LanguageLevel::getSortOrder).thenComparing(LanguageLevel::getId))
                .map(this::toLevelResponse)
                .toList();
    }

    public List<ChapterResponse> getChapters(Long levelId) {
        repository.findLevelById(levelId)
                .orElseThrow(() -> new BusinessException(ErrorCode.LEVEL_NOT_FOUND));
        return repository.findEnabledChaptersByLevelId(levelId).stream()
                .filter(chapter -> Boolean.TRUE.equals(chapter.getEnabled()))
                .sorted(Comparator.comparing(Chapter::getSortOrder).thenComparing(Chapter::getId))
                .map(this::toChapterResponse)
                .toList();
    }

    private String normalizeLanguageCode(String languageCode) {
        return languageCode.trim().toLowerCase(Locale.ROOT);
    }

    private LanguageResponse toLanguageResponse(Language language) {
        return new LanguageResponse(
                language.getId(), language.getCode(), language.getName(), language.getNativeName());
    }

    private LanguageLevelResponse toLevelResponse(LanguageLevel level) {
        return new LanguageLevelResponse(
                level.getId(), level.getCode(), level.getName(), level.getDescription(), level.getSortOrder());
    }

    private ChapterResponse toChapterResponse(Chapter chapter) {
        return new ChapterResponse(
                chapter.getId(), chapter.getTitle(), chapter.getDescription(), chapter.getSortOrder());
    }
}
