package com.grammaragent.review.service;

import org.springframework.stereotype.Component;

import java.time.OffsetDateTime;

/**
 * Stage 6A uses one transparent rule: an incorrect review is due again in one day.
 * Correct reviews are mastered and therefore have no next review time.
 */
@Component
public class ReviewScheduler {

    public OffsetDateTime nextAfterIncorrect(OffsetDateTime reviewedAt) {
        return reviewedAt.plusDays(1);
    }
}
