package com.grammaragent.grammar.repository;

import com.grammaragent.grammar.entity.GrammarPoint;
import com.grammaragent.grammar.entity.GrammarPointPrerequisite;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface GrammarCatalogRepository {

    Optional<GrammarPoint> findEnabledById(Long grammarPointId);

    List<GrammarPoint> findEnabledByChapterId(Long chapterId);

    List<GrammarPoint> findEnabledByChapterIds(Collection<Long> chapterIds);

    List<GrammarPoint> findEnabledPrerequisites(Long grammarPointId);

    List<GrammarPointPrerequisite> findPrerequisitesByGrammarPointIds(Collection<Long> grammarPointIds);
}
