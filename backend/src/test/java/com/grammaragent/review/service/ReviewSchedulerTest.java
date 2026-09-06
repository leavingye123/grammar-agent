package com.grammaragent.review.service;

import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class ReviewSchedulerTest {

    @Test
    void incorrectReviewShouldBeScheduledExactlyOneDayLater() {
        OffsetDateTime reviewedAt = OffsetDateTime.parse("2026-09-06T08:00:00Z");

        assertThat(new ReviewScheduler().nextAfterIncorrect(reviewedAt))
                .isEqualTo(OffsetDateTime.parse("2026-09-07T08:00:00Z"));
    }
}
