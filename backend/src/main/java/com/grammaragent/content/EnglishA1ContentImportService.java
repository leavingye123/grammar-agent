package com.grammaragent.content;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class EnglishA1ContentImportService {

    private final CurriculumContentLoader loader;
    private final CurriculumContentValidator validator;
    private final CurriculumContentWriter writer;

    @Transactional
    public CurriculumContentWriter.ImportResult importEnglishA1() {
        var content = loader.loadEnglishA1();
        var stats = validator.validate(content);
        var result = writer.upsert(content);
        log.info(
                "Imported curriculum {}: {} chapters, {} grammar points, {} lessons, {} questions, {} prerequisites",
                content.version(), result.chapters(), result.grammarPoints(), result.lessons(),
                result.questions(), result.prerequisites());
        if (result.grammarPoints() != stats.grammarPoints()
                || result.lessons() != stats.lessons()
                || result.questions() != stats.questions()
                || result.prerequisites() != stats.prerequisites()) {
            throw new IllegalStateException("Persisted curriculum counts do not match validated source counts");
        }
        return result;
    }
}
