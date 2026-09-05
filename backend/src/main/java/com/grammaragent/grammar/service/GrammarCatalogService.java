package com.grammaragent.grammar.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.course.repository.CourseCatalogRepository;
import com.grammaragent.grammar.dto.GrammarPointDetailResponse;
import com.grammaragent.grammar.dto.GrammarPointSummaryResponse;
import com.grammaragent.grammar.dto.PrerequisiteResponse;
import com.grammaragent.grammar.entity.GrammarPoint;
import com.grammaragent.grammar.repository.GrammarCatalogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Comparator;

@Service
@RequiredArgsConstructor
public class GrammarCatalogService {

    private final CourseCatalogRepository courseRepository;
    private final GrammarCatalogRepository grammarRepository;

    public List<GrammarPointSummaryResponse> getGrammarPoints(Long chapterId) {
        courseRepository.findEnabledChapterById(chapterId)
                .orElseThrow(() -> new BusinessException(ErrorCode.CHAPTER_NOT_FOUND));
        return grammarRepository.findEnabledByChapterId(chapterId).stream()
                .filter(grammarPoint -> Boolean.TRUE.equals(grammarPoint.getEnabled()))
                .sorted(Comparator.comparing(GrammarPoint::getSortOrder).thenComparing(GrammarPoint::getId))
                .map(this::toSummary)
                .toList();
    }

    public GrammarPointDetailResponse getGrammarPoint(Long grammarPointId) {
        GrammarPoint grammarPoint = grammarRepository.findEnabledById(grammarPointId)
                .orElseThrow(() -> new BusinessException(ErrorCode.GRAMMAR_POINT_NOT_FOUND));
        List<PrerequisiteResponse> prerequisites = grammarRepository.findEnabledPrerequisites(grammarPointId).stream()
                .filter(item -> Boolean.TRUE.equals(item.getEnabled()))
                .sorted(Comparator.comparing(GrammarPoint::getSortOrder).thenComparing(GrammarPoint::getId))
                .map(item -> new PrerequisiteResponse(item.getId(), item.getCode(), item.getTitle()))
                .toList();

        return new GrammarPointDetailResponse(
                grammarPoint.getId(),
                grammarPoint.getChapterId(),
                grammarPoint.getCode(),
                grammarPoint.getTitle(),
                grammarPoint.getDescription(),
                grammarPoint.getGrammarRule(),
                grammarPoint.getExamples(),
                grammarPoint.getCommonErrors(),
                grammarPoint.getDifficulty(),
                grammarPoint.getSortOrder(),
                prerequisites);
    }

    private GrammarPointSummaryResponse toSummary(GrammarPoint grammarPoint) {
        return new GrammarPointSummaryResponse(
                grammarPoint.getId(),
                grammarPoint.getCode(),
                grammarPoint.getTitle(),
                grammarPoint.getDescription(),
                grammarPoint.getDifficulty(),
                grammarPoint.getSortOrder());
    }
}
