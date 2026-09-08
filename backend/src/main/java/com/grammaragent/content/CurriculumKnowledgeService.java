package com.grammaragent.content;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Read-only access to authored teaching knowledge. The same content can later be
 * supplied to a tutor agent without coupling that agent to controllers or Flutter.
 */
@Service
@RequiredArgsConstructor
public class CurriculumKnowledgeService {

    private final CurriculumContentLoader loader;
    private final ObjectMapper objectMapper;

    public JsonNode findMicroLesson(String grammarPointCode) {
        Map<String, com.grammaragent.content.model.CurriculumContent.GrammarPointContent> points =
                loader.loadEnglishA1().chapters().stream()
                        .flatMap(chapter -> chapter.grammarPoints().stream())
                        .collect(Collectors.toMap(point -> point.code(), Function.identity()));
        var point = points.get(grammarPointCode);
        return point == null || point.microLesson() == null
                ? null
                : objectMapper.valueToTree(point.microLesson());
    }
}

