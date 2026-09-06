package com.grammaragent.question.repository;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.OffsetDateTime;

@Getter
@Setter
@NoArgsConstructor
public class WrongQuestionSummary {

    private long dueCount;
    private long unmasteredCount;
    private long masteredCount;
    private OffsetDateTime nextReviewAt;
}
