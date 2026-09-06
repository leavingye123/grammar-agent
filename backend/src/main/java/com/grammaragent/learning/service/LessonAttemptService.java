package com.grammaragent.learning.service;

import com.grammaragent.learning.dto.LessonAttemptResponse;
import com.grammaragent.learning.entity.LessonAttempt;
import com.grammaragent.learning.repository.LessonAttemptRepository;
import com.grammaragent.question.service.QuestionContextService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonAttemptService {

    private final LessonAttemptRepository lessonAttemptRepository;
    private final QuestionContextService contextService;

    public List<LessonAttemptResponse> getAttempts(Long userId, Long lessonId) {
        contextService.requireEnabledLesson(lessonId);
        return lessonAttemptRepository.findByUserAndLesson(userId, lessonId).stream()
                .map(LessonAttemptService::toResponse)
                .toList();
    }

    private static LessonAttemptResponse toResponse(LessonAttempt attempt) {
        return new LessonAttemptResponse(
                attempt.getId(),
                attempt.getLessonId(),
                attempt.getStatus(),
                attempt.getStartedAt(),
                attempt.getCompletedAt(),
                attempt.getTotalCount(),
                attempt.getCorrectCount(),
                attempt.getScore(),
                attempt.getXpEarned());
    }
}
