package com.grammaragent.content;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.content.model.CurriculumContent;
import com.grammaragent.content.model.MicroLessonCatalog;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class CurriculumContentLoader {

    public static final String ENGLISH_A1_RESOURCE = "content/en/a1/curriculum.json";
    public static final String ENGLISH_A1_MICRO_LESSONS_RESOURCE = "content/en/a1/micro-lessons.json";

    private final ObjectMapper objectMapper;

    public CurriculumContent loadEnglishA1() {
        CurriculumContent curriculum = read(ENGLISH_A1_RESOURCE, CurriculumContent.class);
        MicroLessonCatalog microLessons = read(ENGLISH_A1_MICRO_LESSONS_RESOURCE, MicroLessonCatalog.class);
        Map<String, MicroLessonCatalog.MicroLessonEntry> byPoint = microLessons.microLessons().stream()
                .collect(Collectors.toMap(MicroLessonCatalog.MicroLessonEntry::grammarPointCode, Function.identity()));
        var chapters = curriculum.chapters().stream()
                .map(chapter -> new CurriculumContent.ChapterContent(
                        chapter.key(),
                        chapter.title(),
                        chapter.description(),
                        chapter.sortOrder(),
                        chapter.grammarPoints().stream().map(point -> {
                            var entry = byPoint.get(point.code());
                            return new CurriculumContent.GrammarPointContent(
                                    point.code(), point.title(), point.description(), point.grammarRule(),
                                    point.examples(), point.commonErrors(), point.difficulty(), point.sortOrder(),
                                    point.prerequisiteCodes(), point.lessons(),
                                    entry == null ? point.microLesson() : entry.toContent());
                        }).toList()))
                .toList();
        return new CurriculumContent(
                curriculum.version(), curriculum.languageCode(), curriculum.languageName(), curriculum.nativeName(),
                curriculum.levelCode(), curriculum.levelName(), curriculum.levelDescription(), chapters);
    }

    public MicroLessonCatalog loadEnglishA1MicroLessons() {
        return read(ENGLISH_A1_MICRO_LESSONS_RESOURCE, MicroLessonCatalog.class);
    }

    private <T> T read(String resource, Class<T> type) {
        try (var input = new ClassPathResource(resource).getInputStream()) {
            return objectMapper.readValue(input, type);
        } catch (IOException exception) {
            throw new UncheckedIOException("Unable to load " + resource, exception);
        }
    }
}
