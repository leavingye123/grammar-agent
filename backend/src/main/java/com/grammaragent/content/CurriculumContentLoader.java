package com.grammaragent.content;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.content.model.CurriculumContent;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.UncheckedIOException;

@Component
@RequiredArgsConstructor
public class CurriculumContentLoader {

    public static final String ENGLISH_A1_RESOURCE = "content/en/a1/curriculum.json";

    private final ObjectMapper objectMapper;

    public CurriculumContent loadEnglishA1() {
        try (var input = new ClassPathResource(ENGLISH_A1_RESOURCE).getInputStream()) {
            return objectMapper.readValue(input, CurriculumContent.class);
        } catch (IOException exception) {
            throw new UncheckedIOException("Unable to load " + ENGLISH_A1_RESOURCE, exception);
        }
    }
}
