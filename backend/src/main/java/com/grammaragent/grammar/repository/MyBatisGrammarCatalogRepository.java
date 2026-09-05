package com.grammaragent.grammar.repository;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.grammaragent.grammar.entity.GrammarPoint;
import com.grammaragent.grammar.entity.GrammarPointPrerequisite;
import com.grammaragent.grammar.mapper.GrammarPointMapper;
import com.grammaragent.grammar.mapper.GrammarPointPrerequisiteMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MyBatisGrammarCatalogRepository implements GrammarCatalogRepository {

    private final GrammarPointMapper grammarPointMapper;
    private final GrammarPointPrerequisiteMapper prerequisiteMapper;

    @Override
    public Optional<GrammarPoint> findEnabledById(Long grammarPointId) {
        return Optional.ofNullable(grammarPointMapper.selectOne(Wrappers.<GrammarPoint>lambdaQuery()
                .eq(GrammarPoint::getId, grammarPointId)
                .eq(GrammarPoint::getEnabled, true)));
    }

    @Override
    public List<GrammarPoint> findEnabledByChapterId(Long chapterId) {
        return grammarPointMapper.selectList(Wrappers.<GrammarPoint>lambdaQuery()
                .eq(GrammarPoint::getChapterId, chapterId)
                .eq(GrammarPoint::getEnabled, true)
                .orderByAsc(GrammarPoint::getSortOrder, GrammarPoint::getId));
    }

    @Override
    public List<GrammarPoint> findEnabledByChapterIds(Collection<Long> chapterIds) {
        if (chapterIds.isEmpty()) {
            return List.of();
        }
        return grammarPointMapper.selectList(Wrappers.<GrammarPoint>lambdaQuery()
                .in(GrammarPoint::getChapterId, chapterIds)
                .eq(GrammarPoint::getEnabled, true)
                .orderByAsc(GrammarPoint::getChapterId, GrammarPoint::getSortOrder, GrammarPoint::getId));
    }

    @Override
    public List<GrammarPoint> findEnabledPrerequisites(Long grammarPointId) {
        List<Long> prerequisiteIds = prerequisiteMapper.selectList(
                        Wrappers.<GrammarPointPrerequisite>lambdaQuery()
                                .eq(GrammarPointPrerequisite::getGrammarPointId, grammarPointId))
                .stream()
                .map(GrammarPointPrerequisite::getPrerequisiteGrammarPointId)
                .toList();
        if (prerequisiteIds.isEmpty()) {
            return List.of();
        }
        return grammarPointMapper.selectList(Wrappers.<GrammarPoint>lambdaQuery()
                .in(GrammarPoint::getId, prerequisiteIds)
                .eq(GrammarPoint::getEnabled, true)
                .orderByAsc(GrammarPoint::getSortOrder, GrammarPoint::getId));
    }
}
