package com.grammaragent.review.service;

import com.grammaragent.question.dto.QuestionResponse;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.entity.WrongQuestion;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.question.repository.WrongQuestionRepository;
import com.grammaragent.question.repository.WrongQuestionSummary;
import com.grammaragent.review.dto.ReviewQuestionResponse;
import com.grammaragent.review.dto.ReviewSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReviewQueryService {

    private final WrongQuestionRepository wrongQuestionRepository;
    private final QuestionRepository questionRepository;

    @Transactional(readOnly = true)
    public List<ReviewQuestionResponse> getDue(Long userId, int limit) {
        return enrich(wrongQuestionRepository.findDueByUserId(userId, utcNow(), limit));
    }

    @Transactional(readOnly = true)
    public List<ReviewQuestionResponse> getUnmastered(Long userId, int page, int size) {
        int offset = Math.multiplyExact(page - 1, size);
        return enrich(wrongQuestionRepository.findUnmasteredByUserId(userId, offset, size));
    }

    @Transactional(readOnly = true)
    public ReviewSummaryResponse getSummary(Long userId) {
        WrongQuestionSummary summary = wrongQuestionRepository.summarize(userId, utcNow());
        return new ReviewSummaryResponse(
                summary.getDueCount(),
                summary.getUnmasteredCount(),
                summary.getMasteredCount(),
                summary.getNextReviewAt());
    }

    private List<ReviewQuestionResponse> enrich(List<WrongQuestion> wrongQuestions) {
        Map<Long, Question> questionsById = questionRepository.findEnabledByIds(
                        wrongQuestions.stream().map(WrongQuestion::getQuestionId).toList())
                .stream()
                .collect(Collectors.toMap(Question::getId, Function.identity()));

        return wrongQuestions.stream()
                .filter(item -> questionsById.containsKey(item.getQuestionId()))
                .map(item -> toResponse(item, questionsById.get(item.getQuestionId())))
                .toList();
    }

    private ReviewQuestionResponse toResponse(WrongQuestion item, Question question) {
        QuestionResponse safeQuestion = new QuestionResponse(
                question.getId(),
                question.getQuestionCode(),
                question.getQuestionType(),
                question.getQuestionContent(),
                question.getOptions(),
                question.getDifficulty(),
                question.getSortOrder());
        return new ReviewQuestionResponse(
                item.getId(),
                safeQuestion,
                item.getWrongCount(),
                item.getLastWrongAt(),
                item.getNextReviewAt());
    }

    private OffsetDateTime utcNow() {
        return OffsetDateTime.now(ZoneOffset.UTC);
    }
}
