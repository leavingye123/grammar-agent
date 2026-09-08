package com.grammaragent.question.service;

import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.question.dto.QuestionResponse;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class QuestionQueryService {

    private final QuestionRepository questionRepository;
    private final QuestionContextService contextService;

    public List<QuestionResponse> getLessonQuestions(Long lessonId) {
        Lesson lesson = contextService.requireEnabledLesson(lessonId);
        List<Question> questions = questionRepository.findEnabledByLessonId(lessonId);
        questions.forEach(question -> contextService.validateQuestion(question, lesson));
        return questions.stream()
                .filter(question -> Boolean.TRUE.equals(question.getEnabled()))
                .sorted(Comparator.comparing(Question::getSortOrder).thenComparing(Question::getId))
                .map(this::toResponse)
                .toList();
    }

    private QuestionResponse toResponse(Question question) {
        return new QuestionResponse(
                question.getId(),
                question.getQuestionCode(),
                question.getQuestionType(),
                question.getQuestionContent(),
                question.getOptions(),
                question.getDifficulty(),
                question.getSortOrder());
    }
}
